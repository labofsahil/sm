use std::path::{Component, Path, PathBuf};
use std::sync::Mutex;
use std::str::FromStr;
use std::time::Duration;
use once_cell::sync::Lazy;
use tracing::{debug, error, info, warn};

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

// ─── Progress Enums ──────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq)]
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

#[derive(Debug, Clone, PartialEq)]
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

// ─── Progress Reporter Traits ────────────────────────────────────

pub trait SendProgressReporter: Send + Sync + 'static {
    fn report(&self, progress: SendProgress);
}

impl SendProgressReporter for StreamSink<SendProgress> {
    fn report(&self, progress: SendProgress) {
        let _ = self.add(progress);
    }
}

pub trait ReceiveProgressReporter: Send + Sync + 'static {
    fn report(&self, progress: ReceiveProgress);
}

impl ReceiveProgressReporter for StreamSink<ReceiveProgress> {
    fn report(&self, progress: ReceiveProgress) {
        let _ = self.add(progress);
    }
}

// ─── Session State ───────────────────────────────────────────────

struct SendSession {
    router: Router,
    /// Kept alive to prevent the blob from being garbage collected.
    #[allow(dead_code)]
    temp_tag: TempTag,
    blobs_data_dir: PathBuf,
}

struct ReceiveSession {
    cancel_tx: oneshot::Sender<()>,
}

static ACTIVE_SEND: Lazy<Mutex<Option<SendSession>>> = Lazy::new(|| Mutex::new(None));
static ACTIVE_RECEIVE: Lazy<Mutex<Option<ReceiveSession>>> = Lazy::new(|| Mutex::new(None));

// ─── Public API ──────────────────────────────────────────────────

/// Start sharing a file or directory.
///
/// This is an async function that streams progress events back to Dart.
/// flutter_rust_bridge will run it on its own tokio runtime.
pub async fn start_send(
    path: String,
    temp_dir: String,
    sink: StreamSink<SendProgress>,
) {
    if let Err(e) = start_send_inner(path, temp_dir, &sink).await {
        let _ = sink.add(SendProgress::Failed {
            error: e.to_string(),
        });
    }
}

/// Stop an active send session and clean up resources.
pub fn stop_send() -> anyhow::Result<()> {
    let mut guard = ACTIVE_SEND.lock().unwrap();
    if let Some(session) = guard.take() {
        // Spawn the async cleanup onto the current tokio runtime.
        // This is safe because FRB provides a tokio runtime context.
        tokio::spawn(async move {
            let _ = session.router.shutdown().await;
            let _ = tokio::fs::remove_dir_all(session.blobs_data_dir).await;
        });
    }
    Ok(())
}

/// Start receiving (downloading) data using a sendme ticket.
///
/// This is an async function that streams progress events back to Dart.
pub async fn start_receive(
    ticket_str: String,
    temp_dir: String,
    destination_dir: String,
    sink: StreamSink<ReceiveProgress>,
) {
    if let Err(e) = start_receive_inner(ticket_str, temp_dir, destination_dir, &sink).await {
        let _ = sink.add(ReceiveProgress::Failed {
            error: e.to_string(),
        });
    }
}

/// Cancel an active receive session.
pub fn cancel_receive() -> anyhow::Result<()> {
    let mut guard = ACTIVE_RECEIVE.lock().unwrap();
    if let Some(session) = guard.take() {
        let _ = session.cancel_tx.send(());
    }
    Ok(())
}

// ─── Send Implementation ─────────────────────────────────────────

async fn start_send_inner(
    path_str: String,
    temp_dir_str: String,
    reporter: &impl SendProgressReporter,
) -> anyhow::Result<()> {
    info!("[SEND] start_send_inner called: path={}", path_str);

    // 1. Clean up any existing send session
    let _ = stop_send();

    reporter.report(SendProgress::StartingEndpoint);

    // 2. Generate a fresh secret key for this session
    let secret_key = iroh::SecretKey::generate();
    info!("[SEND] Generated secret key, binding endpoint...");

    // 3. Create the iroh endpoint with the N0 preset
    let endpoint = Endpoint::builder(iroh::endpoint::presets::N0)
        .alpns(vec![ALPN.to_vec()])
        .secret_key(secret_key)
        .relay_mode(RelayMode::Default)
        .bind()
        .await
        .map_err(|e| { error!("[SEND] Failed to bind endpoint: {}", e); e })?;

    info!("[SEND] Endpoint bound. ID: {}", endpoint.id());

    // 4. Set up a temporary blobs directory
    let suffix: [u8; 16] = rand::random();
    let blobs_data_dir = PathBuf::from(&temp_dir_str)
        .join(format!(".sendme-send-{}", hex::encode(suffix)));
    tokio::fs::create_dir_all(&blobs_data_dir).await?;
    info!("[SEND] Blob store dir: {}", blobs_data_dir.display());

    let store = FsStore::load(&blobs_data_dir).await
        .map_err(|e| { error!("[SEND] FsStore::load failed: {}", e); e })?;
    let blobs = iroh_blobs::BlobsProtocol::new(&store, None);

    // 5. Import the file or directory
    let path = PathBuf::from(&path_str);
    info!("[SEND] Importing path: {}", path.display());
    let (temp_tag, size, _collection) = import_with_progress(path, &store, reporter).await
        .map_err(|e| { error!("[SEND] Import failed: {}", e); e })?;
    info!("[SEND] Import done. Hash={}, size={}", temp_tag.hash(), size);

    // 6. Set up the protocol router to serve blobs
    let router = Router::builder(endpoint)
        .accept(ALPN, blobs)
        .spawn();
    info!("[SEND] Router spawned, waiting for relay online...");

    // 7. Wait for the endpoint to come online
    let ep = router.endpoint().clone();
    match tokio::time::timeout(Duration::from_secs(30), async move {
        let _ = ep.online().await;
    }).await {
        Ok(_) => info!("[SEND] Endpoint online (relay connected)"),
        Err(_) => warn!("[SEND] Timeout waiting for relay — using local addresses only"),
    }

    // 8. Generate the share ticket
    let addr = router.endpoint().addr();
    info!("[SEND] Node addr: {:?}", addr);
    let hash = temp_tag.hash();
    let ticket = BlobTicket::new(addr, hash, BlobFormat::HashSeq);
    let ticket_str = ticket.to_string();
    info!("[SEND] Ticket generated: {}", ticket_str);

    // 9. Store session (temp_tag kept alive to prevent GC)
    let session = SendSession {
        router,
        temp_tag,
        blobs_data_dir,
    };
    *ACTIVE_SEND.lock().unwrap() = Some(session);

    reporter.report(SendProgress::Sharing { ticket: ticket_str });
    info!("[SEND] Sharing event emitted, session active");

    Ok(())
}

// ─── Receive Implementation ──────────────────────────────────────

async fn start_receive_inner(
    ticket_str: String,
    temp_dir_str: String,
    destination_dir_str: String,
    reporter: &impl ReceiveProgressReporter,
) -> anyhow::Result<()> {
    info!("[RECV] start_receive_inner called");

    // 1. Cancel any existing receive session
    let _ = cancel_receive();

    // 2. Create a cancellation channel
    let (cancel_tx, mut cancel_rx) = oneshot::channel::<()>();
    *ACTIVE_RECEIVE.lock().unwrap() = Some(ReceiveSession { cancel_tx });

    // 3. Parse the ticket
    let ticket = BlobTicket::from_str(&ticket_str)
        .map_err(|e| { error!("[RECV] Invalid ticket: {}", e); e })?;
    let addr = ticket.addr().clone();
    info!("[RECV] Ticket parsed. Hash={}, format={:?}", ticket.hash(), ticket.format());
    info!("[RECV] Peer addr: relay_urls={:?}, ip_addrs={:?}",
        ticket.addr().relay_urls().collect::<Vec<_>>(),
        ticket.addr().ip_addrs().collect::<Vec<_>>());

    reporter.report(ReceiveProgress::Connecting);

    // 4. Create a receiver endpoint
    let secret_key = iroh::SecretKey::generate();
    let has_relay = ticket.addr().relay_urls().next().is_some();
    let has_direct = ticket.addr().ip_addrs().next().is_some();
    info!("[RECV] has_relay={}, has_direct={}", has_relay, has_direct);

    let mut builder = Endpoint::builder(iroh::endpoint::presets::N0)
        .alpns(vec![])
        .secret_key(secret_key)
        .relay_mode(RelayMode::Default);

    if !has_relay && !has_direct {
        warn!("[RECV] No relay/direct addresses — enabling DNS lookup");
        builder = builder.address_lookup(iroh::address_lookup::DnsAddressLookup::n0_dns());
    }

    let endpoint = builder.bind().await
        .map_err(|e| { error!("[RECV] Endpoint bind failed: {}", e); e })?;
    info!("[RECV] Receiver endpoint bound. ID: {}", endpoint.id());

    // 5. Set up temp blob store
    let dir_name = format!(".sendme-recv-{}", ticket.hash().to_hex());
    let iroh_data_dir = PathBuf::from(&temp_dir_str).join(&dir_name);
    tokio::fs::create_dir_all(&iroh_data_dir).await?;
    info!("[RECV] Blob store dir: {}", iroh_data_dir.display());

    let db = FsStore::load(&iroh_data_dir).await
        .map_err(|e| { error!("[RECV] FsStore::load failed: {}", e); e })?;
    let db_clone = db.clone();

    // 6. Run the receive with cancellation
    let receive_fut = async {
        let hash_and_format = ticket.hash_and_format();
        let local = db.remote().local(hash_and_format).await?;
        info!("[RECV] Local state: is_complete={}", local.is_complete());

        let (_stats, total_files, payload_size) = if !local.is_complete() {
            info!("[RECV] Connecting to sender at {:?}...", addr);
            let connection = endpoint.connect(addr, iroh_blobs::protocol::ALPN).await
                .map_err(|e| { error!("[RECV] QUIC connect failed: {}", e); e })?;
            info!("[RECV] QUIC connection established!");
            reporter.report(ReceiveProgress::Connected);
            reporter.report(ReceiveProgress::RetrievingMetadata);

            info!("[RECV] Fetching hash sequence and sizes...");
            let (_hash_seq, sizes) = iroh_blobs::get::request::get_hash_seq_and_sizes(
                &connection,
                &hash_and_format.hash,
                1024 * 1024 * 32,
                None,
            ).await
            .map_err(|e| { error!("[RECV] get_hash_seq_and_sizes failed: {}", e); e })?;

            let total_size: u64 = sizes.iter().copied().sum();
            let payload_size: u64 = sizes.iter().skip(2).copied().sum();
            let total_files = sizes.len().saturating_sub(1) as u64;
            info!("[RECV] Metadata: {} files, total_size={}, payload_size={}", total_files, total_size, payload_size);

            let get = db.remote().execute_get(connection, local.missing());
            let mut stream = get.stream();
            let mut stats = iroh_blobs::get::Stats::default();
            let mut last_pct = 0u64;

            while let Some(item) = stream.next().await {
                match item {
                    GetProgressItem::Progress(offset) => {
                        let pct = if total_size > 0 { offset * 100 / total_size } else { 0 };
                        if pct >= last_pct + 10 {
                            debug!("[RECV] Download progress: {}% ({}/{})", pct, offset, total_size);
                            last_pct = pct;
                        }
                        reporter.report(ReceiveProgress::Downloading {
                            bytes_downloaded: offset,
                            total_bytes: total_size,
                            percentage: pct as f64,
                        });
                    }
                    GetProgressItem::Done(value) => {
                        info!("[RECV] Download done: {:?}", value);
                        stats = value;
                        break;
                    }
                    GetProgressItem::Error(cause) => {
                        error!("[RECV] Download stream error: {}", cause);
                        anyhow::bail!("Download error: {}", cause);
                    }
                }
            }
            reporter.report(ReceiveProgress::DownloadDone { total_bytes: total_size });
            (stats, total_files, payload_size)
        } else {
            info!("[RECV] Already fully downloaded locally");
            let total_files = local.children().unwrap_or(1) - 1;
            (iroh_blobs::get::Stats::default(), total_files, 0)
        };

        info!("[RECV] Loading collection from store...");
        let collection = Collection::load(hash_and_format.hash, db.as_ref()).await
            .map_err(|e| { error!("[RECV] Collection::load failed: {}", e); e })?;
        info!("[RECV] Collection loaded: {} entries", collection.len());

        reporter.report(ReceiveProgress::Exporting {
            file_name: String::new(),
            bytes_exported: 0,
            bytes_total: payload_size,
        });

        info!("[RECV] Exporting to: {}", destination_dir_str);
        export_with_progress(&db, collection, &destination_dir_str, reporter).await
            .map_err(|e| { error!("[RECV] Export failed: {}", e); e })?;

        info!("[RECV] Export complete! total_files={}, payload_size={}", total_files, payload_size);
        anyhow::Ok((total_files, payload_size))
    };

    let result = tokio::select! {
        res = receive_fut => { endpoint.close().await; res }
        _ = &mut cancel_rx => {
            warn!("[RECV] Cancelled by user");
            endpoint.close().await;
            anyhow::bail!("Receive operation cancelled by user")
        }
    };

    let _ = db_clone.shutdown().await;
    let _ = tokio::fs::remove_dir_all(iroh_data_dir).await;
    *ACTIVE_RECEIVE.lock().unwrap() = None;

    match result {
        Ok((files, bytes)) => {
            reporter.report(ReceiveProgress::Finished { total_files: files, total_bytes: bytes });
        }
        Err(e) => {
            error!("[RECV] Failed: {}", e);
            reporter.report(ReceiveProgress::Failed { error: e.to_string() });
        }
    }

    Ok(())
}

// ─── Import Helpers ──────────────────────────────────────────────

async fn import_with_progress(
    path: PathBuf,
    db: &FsStore,
    reporter: &impl SendProgressReporter,
) -> anyhow::Result<(TempTag, u64, Collection)> {
    let path = path.canonicalize()?;
    anyhow::ensure!(path.exists(), "path {} does not exist", path.display());
    let root = path
        .parent()
        .ok_or_else(|| anyhow::anyhow!("No parent directory"))?;

    // Collect all files to import
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

    anyhow::ensure!(!files.is_empty(), "no files found to import");

    let mut names_and_tags = Vec::new();

    for (name, file_path) in files.into_iter() {
        let import = db.add_path_with_opts(AddPathOptions {
            path: file_path,
            mode: ImportMode::TryReference,
            format: BlobFormat::Raw,
        });

        let mut stream = import.stream().await;
        let mut item_size = 0u64;
        let temp_tag = loop {
            let item = stream
                .next()
                .await
                .ok_or_else(|| anyhow::anyhow!("import stream ended without a tag"))?;

            match item {
                AddProgressItem::Size(size) => {
                    item_size = size;
                    reporter.report(SendProgress::Importing {
                        file_name: name.clone(),
                        bytes_done: 0,
                        bytes_total: size,
                    });
                }
                AddProgressItem::CopyProgress(offset) => {
                    reporter.report(SendProgress::Importing {
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

    // Build the collection from (name, hash) pairs
    let (collection, tags) = names_and_tags
        .into_iter()
        .map(|(name, tag, _)| ((name, tag.hash()), tag))
        .unzip::<_, _, Collection, Vec<_>>();

    // Store the collection into the blob store; this returns a TempTag for the HashSeq
    let temp_tag = collection.clone().store(db.as_ref()).await?;
    // Now that the collection is stored, the individual blob tags can be dropped
    // since they are protected by the collection's HashSeq
    drop(tags);

    reporter.report(SendProgress::ImportDone { total_size });
    Ok((temp_tag, total_size, collection))
}

// ─── Export Helpers ──────────────────────────────────────────────

async fn export_with_progress(
    db: &FsStore,
    collection: Collection,
    destination_dir: &str,
    reporter: &impl ReceiveProgressReporter,
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

        reporter.report(ReceiveProgress::Exporting {
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

// ─── Path Utilities ──────────────────────────────────────────────

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

// ─── Unit / Integration Tests ────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::Arc;

    struct TestSendReporter {
        events: Arc<Mutex<Vec<SendProgress>>>,
    }

    impl SendProgressReporter for TestSendReporter {
        fn report(&self, progress: SendProgress) {
            self.events.lock().unwrap().push(progress);
        }
    }

    struct TestReceiveReporter {
        events: Arc<Mutex<Vec<ReceiveProgress>>>,
    }

    impl ReceiveProgressReporter for TestReceiveReporter {
        fn report(&self, progress: ReceiveProgress) {
            self.events.lock().unwrap().push(progress);
        }
    }

    #[tokio::test]
    async fn test_send_receive_local() -> anyhow::Result<()> {
        // Create a temporary directory structure for the test
        let temp_base = std::env::temp_dir().join(format!("sendme-test-{}", rand::random::<u32>()));
        tokio::fs::create_dir_all(&temp_base).await?;

        let source_dir = temp_base.join("source");
        let temp_dir = temp_base.join("temp");
        let dest_dir = temp_base.join("dest");

        tokio::fs::create_dir_all(&source_dir).await?;
        tokio::fs::create_dir_all(&temp_dir).await?;
        tokio::fs::create_dir_all(&dest_dir).await?;

        // Create a test file
        let file_path = source_dir.join("hello.txt");
        let file_content = b"Hello from Sendme P2P File Sharing Bridge!";
        tokio::fs::write(&file_path, file_content).await?;

        // Start send
        let send_events = Arc::new(Mutex::new(Vec::new()));
        let send_reporter = TestSendReporter {
            events: send_events.clone(),
        };

        start_send_inner(
            file_path.to_string_lossy().to_string(),
            temp_dir.to_string_lossy().to_string(),
            &send_reporter,
        )
        .await?;

        // Extract ticket
        let mut ticket_str = String::new();
        {
            let events = send_events.lock().unwrap();
            for event in events.iter() {
                if let SendProgress::Sharing { ticket } = event {
                    ticket_str = ticket.clone();
                }
            }
        }
        assert!(!ticket_str.is_empty(), "Ticket should not be empty");

        // Start receive
        let receive_events = Arc::new(Mutex::new(Vec::new()));
        let receive_reporter = TestReceiveReporter {
            events: receive_events.clone(),
        };

        start_receive_inner(
            ticket_str,
            temp_dir.to_string_lossy().to_string(),
            dest_dir.to_string_lossy().to_string(),
            &receive_reporter,
        )
        .await?;

        // Verify the received file content
        let received_file_path = dest_dir.join("hello.txt");
        assert!(received_file_path.exists(), "Received file should exist at path");

        let received_content = tokio::fs::read(&received_file_path).await?;
        assert_eq!(received_content, file_content, "Content should match");

        // Ensure transfer events show finished status
        let mut finished = false;
        {
            let events = receive_events.lock().unwrap();
            for event in events.iter() {
                if let ReceiveProgress::Finished { .. } = event {
                    finished = true;
                }
            }
        }
        assert!(finished, "Receive should finish successfully");

        // Stop active send session to release locks and endpoints
        stop_send()?;

        // Clean up filesystem
        tokio::fs::remove_dir_all(&temp_base).await?;

        Ok(())
    }
}
