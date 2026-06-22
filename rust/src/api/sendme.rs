use std::path::{Component, Path, PathBuf};
use std::sync::Mutex;
use std::str::FromStr;
use std::time::Duration;
use once_cell::sync::Lazy;
use rand::Rng;

use iroh::Endpoint;
use iroh::RelayMode;
use iroh::protocol::Router;
use iroh_blobs::protocol::ALPN;
use iroh_blobs::ticket::BlobTicket;
use iroh_blobs::store::fs::FsStore;
use iroh_blobs::api::blobs::{AddPathOptions, AddProgressItem, ImportMode, ExportMode, ExportOptions, ExportProgressItem};
use iroh_blobs::api::remote::GetProgressItem;
use iroh_blobs::api::TempTag;
use iroh_blobs::BlobFormat;
use iroh_blobs::format::collection::Collection;
use futures::StreamExt;
use tokio::sync::oneshot;

use crate::frb_generated::StreamSink;

#[derive(Debug, Clone)]
pub enum SendProgress {
    Importing {
        file_name: String,
        bytes_done: u64,
        bytes_total: u64,
    },
    ImportDone {
        total_size: u64,
    },
    StartingEndpoint,
    Sharing {
        ticket: String,
    },
    Failed {
        error: String,
    },
}

#[derive(Debug, Clone)]
pub enum ReceiveProgress {
    Connecting,
    Connected,
    RetrievingMetadata,
    Downloading {
        bytes_downloaded: u64,
        total_bytes: u64,
        percentage: f64,
    },
    DownloadDone {
        total_bytes: u64,
    },
    Exporting {
        file_name: String,
        bytes_exported: u64,
        bytes_total: u64,
    },
    Finished {
        total_files: u64,
        total_bytes: u64,
    },
    Failed {
        error: String,
    },
}

struct SendSession {
    router: Router,
    temp_tag: TempTag,
    blobs_data_dir: PathBuf,
}

struct ReceiveSession {
    cancel_tx: oneshot::Sender<()>,
}

static ACTIVE_SEND: Lazy<Mutex<Option<SendSession>>> = Lazy::new(|| Mutex::new(None));
static ACTIVE_RECEIVE: Lazy<Mutex<Option<ReceiveSession>>> = Lazy::new(|| Mutex::new(None));
static TOKIO_RUNTIME: Lazy<Mutex<Option<tokio::runtime::Runtime>>> = Lazy::new(|| Mutex::new(None));

fn get_runtime() -> tokio::runtime::Handle {
    let mut guard = TOKIO_RUNTIME.lock().unwrap();
    if guard.is_none() {
        let rt = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .expect("Failed to build Tokio runtime");
        *guard = Some(rt);
    }
    guard.as_ref().unwrap().handle().clone()
}

pub fn start_send(
    path: String,
    temp_dir: String,
    sink: StreamSink<SendProgress>,
) {
    let handle = get_runtime();
    handle.spawn(async move {
        if let Err(e) = start_send_inner(path, temp_dir, sink.clone()).await {
            let _ = sink.add(SendProgress::Failed { error: e.to_string() });
        }
    });
}

pub fn stop_send() -> anyhow::Result<()> {
    let mut guard = ACTIVE_SEND.lock().unwrap();
    if let Some(session) = guard.take() {
        let rt = get_runtime();
        rt.spawn(async move {
            let _ = session.router.shutdown().await;
            let _ = tokio::fs::remove_dir_all(session.blobs_data_dir).await;
        });
    }
    Ok(())
}

pub fn start_receive(
    ticket_str: String,
    temp_dir: String,
    destination_dir: String,
    sink: StreamSink<ReceiveProgress>,
) {
    let handle = get_runtime();
    handle.spawn(async move {
        if let Err(e) = start_receive_inner(ticket_str, temp_dir, destination_dir, sink.clone()).await {
            let _ = sink.add(ReceiveProgress::Failed { error: e.to_string() });
        }
    });
}

pub fn cancel_receive() -> anyhow::Result<()> {
    let mut guard = ACTIVE_RECEIVE.lock().unwrap();
    if let Some(session) = guard.take() {
        let _ = session.cancel_tx.send(());
    }
    Ok(())
}

async fn start_send_inner(
    path_str: String,
    temp_dir_str: String,
    sink: StreamSink<SendProgress>,
) -> anyhow::Result<()> {
    // 1. Clean up existing send session
    let _ = stop_send();
    
    let _ = sink.add(SendProgress::StartingEndpoint);
    
    // 2. Secret Key
    let secret_key = iroh::SecretKey::generate();
    
    // 3. Create endpoint builder
    let builder = Endpoint::builder(iroh::endpoint::presets::N0)
        .alpns(vec![ALPN.to_vec()])
        .secret_key(secret_key)
        .relay_mode(RelayMode::Default);
        
    let endpoint = builder.bind().await?;
    
    // 4. Set up temporary blobs directory inside target temp_dir
    let suffix = rand::thread_rng().gen::<[u8; 16]>();
    let blobs_data_dir = PathBuf::from(temp_dir_str).join(format!(".sendme-send-{}", hex::encode(suffix)));
    tokio::fs::create_dir_all(&blobs_data_dir).await?;
    
    let store = FsStore::load(&blobs_data_dir).await?;
    let blobs = iroh_blobs::BlobsProtocol::new(&store, None);
    
    // 5. Import the file or directory
    let path = PathBuf::from(path_str);
    let (temp_tag, _size, _collection) = import_with_progress(path, &store, &sink).await?;
    
    // 6. Router and Endpoint binding
    let router = Router::builder(endpoint)
        .accept(ALPN, blobs)
        .spawn();
        
    // Wait for endpoint to get online (wait for relay connection)
    let ep = router.endpoint().clone();
    let _ = tokio::time::timeout(Duration::from_secs(10), async move {
        let _ = ep.online().await;
    }).await;
    
    // 7. Make ticket
    let addr = router.endpoint().addr();
    let hash = temp_tag.hash();
    let ticket = BlobTicket::new(addr, hash, iroh_blobs::BlobFormat::HashSeq);
    let ticket_str = ticket.to_string();
    
    // Save session
    let session = SendSession {
        router,
        temp_tag,
        blobs_data_dir,
    };
    *ACTIVE_SEND.lock().unwrap() = Some(session);
    
    let _ = sink.add(SendProgress::Sharing { ticket: ticket_str });
    
    Ok(())
}

async fn start_receive_inner(
    ticket_str: String,
    temp_dir_str: String,
    destination_dir_str: String,
    sink: StreamSink<ReceiveProgress>,
) -> anyhow::Result<()> {
    // 1. Cancel any active receive session first
    let _ = cancel_receive();
    
    // Create cancellation channel
    let (cancel_tx, mut cancel_rx) = oneshot::channel::<()>();
    *ACTIVE_RECEIVE.lock().unwrap() = Some(ReceiveSession { cancel_tx });
    
    let ticket = BlobTicket::from_str(&ticket_str)?;
    let addr = ticket.addr().clone();
    
    let _ = sink.add(ReceiveProgress::Connecting);
    
    let secret_key = iroh::SecretKey::generate();
    let mut builder = Endpoint::builder(iroh::endpoint::presets::N0)
        .alpns(vec![])
        .secret_key(secret_key)
        .relay_mode(RelayMode::Default);
        
    if ticket.addr().relay_urls().next().is_none() && ticket.addr().ip_addrs().next().is_none() {
        builder = builder.address_lookup(iroh::address_lookup::DnsAddressLookup::n0_dns());
    }
    
    let endpoint = builder.bind().await?;
    
    // Set up temp directory inside target temp_dir
    let dir_name = format!(".sendme-recv-{}", ticket.hash().to_hex());
    let iroh_data_dir = PathBuf::from(temp_dir_str).join(dir_name);
    tokio::fs::create_dir_all(&iroh_data_dir).await?;
    
    let db = FsStore::load(&iroh_data_dir).await?;
    let db_clone = db.clone();
    
    // Run the main receive future with select to allow cancellation
    let receive_fut = async {
        let hash_and_format = ticket.hash_and_format();
        let local = db.remote().local(hash_and_format).await?;
        
        let (_stats, total_files, payload_size) = if !local.is_complete() {
            let connection = endpoint.connect(addr, iroh_blobs::protocol::ALPN).await?;
            let _ = sink.add(ReceiveProgress::Connected);
            let _ = sink.add(ReceiveProgress::RetrievingMetadata);
            
            let (_hash_seq, sizes) = iroh_blobs::get::request::get_hash_seq_and_sizes(
                &connection,
                &hash_and_format.hash,
                1024 * 1024 * 32,
                None,
            )
            .await?;
            
            let total_size = sizes.iter().copied().sum::<u64>();
            let payload_size = sizes.iter().skip(2).copied().sum::<u64>();
            let total_files = (sizes.len().saturating_sub(1)) as u64;
            
            let get = db.remote().execute_get(connection, local.missing());
            let mut stream = get.stream();
            let mut stats = iroh_blobs::get::Stats::default();
            
            while let Some(item) = stream.next().await {
                match item {
                    GetProgressItem::Progress(offset) => {
                        let percentage = if total_size > 0 {
                            (offset as f64 / total_size as f64) * 100.0
                        } else {
                            0.0
                        };
                        let _ = sink.add(ReceiveProgress::Downloading {
                            bytes_downloaded: offset,
                            total_bytes: total_size,
                            percentage,
                        });
                    }
                    GetProgressItem::Done(value) => {
                        stats = value;
                        break;
                    }
                    GetProgressItem::Error(cause) => {
                        anyhow::bail!("Download error: {}", cause);
                    }
                }
            }
            let _ = sink.add(ReceiveProgress::DownloadDone { total_bytes: total_size });
            (stats, total_files, payload_size)
        } else {
            let total_files = local.children().unwrap_or(1) - 1;
            (iroh_blobs::get::Stats::default(), total_files, 0)
        };
        
        let collection = Collection::load(hash_and_format.hash, db.as_ref()).await?;
        
        // Export collection
        let _ = sink.add(ReceiveProgress::Exporting {
            file_name: "".to_string(),
            bytes_exported: 0,
            bytes_total: payload_size,
        });
        
        export_with_progress(&db, collection, &destination_dir_str, &sink).await?;
        
        anyhow::Ok((total_files, payload_size))
    };
    
    let result = tokio::select! {
        res = receive_fut => {
            endpoint.close().await;
            res
        }
        _ = &mut cancel_rx => {
            endpoint.close().await;
            anyhow::bail!("Receive operation cancelled by user")
        }
    };
    
    // Clean up
    let _ = db_clone.shutdown().await;
    let _ = tokio::fs::remove_dir_all(iroh_data_dir).await;
    
    // Clear receive state
    *ACTIVE_RECEIVE.lock().unwrap() = None;
    
    match result {
        Ok((files, bytes)) => {
            let _ = sink.add(ReceiveProgress::Finished {
                total_files: files,
                total_bytes: bytes,
            });
        }
        Err(e) => {
            let _ = sink.add(ReceiveProgress::Failed { error: e.to_string() });
        }
    }
    
    Ok(())
}

async fn import_with_progress(
    path: PathBuf,
    db: &FsStore,
    sink: &StreamSink<SendProgress>,
) -> anyhow::Result<(TempTag, u64, Collection)> {
    let path = path.canonicalize()?;
    anyhow::ensure!(path.exists(), "path {} does not exist", path.display());
    let root = path.parent().ok_or_else(|| anyhow::anyhow!("No parent directory"))?;
    
    let mut files = Vec::new();
    if path.is_file() {
        let relative = path.strip_prefix(root)?;
        let name = canonicalized_path_to_string(relative, true)?;
        files.push((name, path.clone()));
    } else {
        for entry in walkdir::WalkDir::new(&path) {
            let entry = entry?;
            if entry.file_type().is_file() {
                let p = entry.into_path();
                let relative = p.strip_prefix(root)?;
                let name = canonicalized_path_to_string(relative, true)?;
                files.push((name, p));
            }
        }
    }

    let mut names_and_tags = Vec::new();
    
    for (name, file_path) in files.into_iter() {
        let import = db.add_path_with_opts(AddPathOptions {
            path: file_path,
            mode: ImportMode::TryReference,
            format: BlobFormat::Raw,
        });
        
        let mut stream = import.stream().await;
        let mut item_size = 0;
        let temp_tag = loop {
            let item = stream
                .next()
                .await
                .ok_or_else(|| anyhow::anyhow!("import stream ended without a tag"))?;
            
            match item {
                AddProgressItem::Size(size) => {
                    item_size = size;
                    let _ = sink.add(SendProgress::Importing {
                        file_name: name.clone(),
                        bytes_done: 0,
                        bytes_total: size,
                    });
                }
                AddProgressItem::CopyProgress(offset) => {
                    let _ = sink.add(SendProgress::Importing {
                        file_name: name.clone(),
                        bytes_done: offset,
                        bytes_total: item_size,
                    });
                }
                AddProgressItem::CopyDone => {}
                AddProgressItem::OutboardProgress(_) => {}
                AddProgressItem::Error(cause) => {
                    anyhow::bail!("error importing {}: {}", name, cause);
                }
                AddProgressItem::Done(tt) => {
                    break tt;
                }
            }
        };
        names_and_tags.push((name, temp_tag, item_size));
    }

    names_and_tags.sort_by(|(a, _, _), (b, _, _)| a.cmp(b));
    let total_size = names_and_tags.iter().map(|(_, _, size)| *size).sum::<u64>();
    
    let (collection, tags) = names_and_tags
        .into_iter()
        .map(|(name, tag, _)| ((name, tag.hash()), tag))
        .unzip::<_, _, Collection, Vec<_>>();
        
    let temp_tag = collection.clone().store(db).await?;
    drop(tags);
    
    let _ = sink.add(SendProgress::ImportDone { total_size });
    Ok((temp_tag, total_size, collection))
}

async fn export_with_progress(
    db: &FsStore,
    collection: Collection,
    destination_dir: &str,
    sink: &StreamSink<ReceiveProgress>,
) -> anyhow::Result<()> {
    let root = PathBuf::from(destination_dir);
    let total_blobs = collection.len();
    
    for (idx, (name, hash)) in collection.iter().enumerate() {
        let target = get_export_path(&root, name)?;
        if target.exists() {
            anyhow::bail!("target file already exists: {}", target.display());
        }
        
        if let Some(parent) = target.parent() {
            tokio::fs::create_dir_all(parent).await?;
        }
        
        let _ = sink.add(ReceiveProgress::Exporting {
            file_name: name.clone(),
            bytes_exported: idx as u64,
            bytes_total: total_blobs as u64,
        });
        
        let mut stream = db
            .export_with_opts(ExportOptions {
                hash: *hash,
                target,
                mode: ExportMode::Copy,
            })
            .stream()
            .await;
            
        while let Some(item) = stream.next().await {
            match item {
                ExportProgressItem::Size(_) => {}
                ExportProgressItem::CopyProgress(_) => {}
                ExportProgressItem::Done => {}
                ExportProgressItem::Error(cause) => {
                    anyhow::bail!("Error exporting {}: {}", name, cause);
                }
            }
        }
    }
    
    Ok(())
}

fn validate_path_component(component: &str) -> anyhow::Result<()> {
    anyhow::ensure!(
        !component.contains('/'),
        "path components must not contain /"
    );
    Ok(())
}

fn get_export_path(root: &Path, name: &str) -> anyhow::Result<PathBuf> {
    let parts = name.split('/');
    let mut path = root.to_path_buf();
    for part in parts {
        validate_path_component(part)?;
        path.push(part);
    }
    Ok(path)
}

fn canonicalized_path_to_string(
    path: impl AsRef<Path>,
    must_be_relative: bool,
) -> anyhow::Result<String> {
    let mut path_str = String::new();
    let parts = path
        .as_ref()
        .components()
        .filter_map(|c| match c {
            Component::Normal(x) => {
                let c = match x.to_str() {
                    Some(c) => c,
                    None => return Some(Err(anyhow::anyhow!("invalid character in path"))),
                };

                if !c.contains('/') && !c.contains('\\') {
                    Some(Ok(c))
                } else {
                    Some(Err(anyhow::anyhow!("invalid path component {:?}", c)))
                }
            }
            Component::RootDir => {
                if must_be_relative {
                    Some(Err(anyhow::anyhow!("invalid path component {:?}", c)))
                } else {
                    path_str.push('/');
                    None
                }
            }
            _ => Some(Err(anyhow::anyhow!("invalid path component {:?}", c))),
        })
        .collect::<anyhow::Result<Vec<_>>>()?;
    let parts = parts.join("/");
    path_str.push_str(&parts);
    Ok(path_str)
}
