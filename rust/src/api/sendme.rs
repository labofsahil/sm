//! Core Iroh-based P2P file sharing implementation.
//!
//! Provides asynchronous routines for importing local files/directories into an Iroh
//! blob store, serving them over QUIC/Relay tickets, and downloading/exporting
//! received collections to target destinations.

use std::path::{Component, Path, PathBuf};
use std::str::FromStr;
use std::sync::Mutex;
use std::time::Duration;

use futures::StreamExt;
use iroh::protocol::Router;
use iroh::Endpoint;
use iroh::RelayMode;
use iroh_blobs::api::blobs::{AddPathOptions, AddProgressItem, ImportMode};
use iroh_blobs::api::remote::GetProgressItem;
use iroh_blobs::api::TempTag;
use iroh_blobs::format::collection::Collection;
use iroh_blobs::protocol::ALPN;
use iroh_blobs::store::fs::FsStore;
use iroh_blobs::ticket::BlobTicket;
use iroh_blobs::BlobFormat;
use once_cell::sync::Lazy;
use tokio::sync::{oneshot, watch};
use tracing::{debug, error, info, warn};

use crate::frb_generated::StreamSink;

// ─── Progress Enums ──────────────────────────────────────────────

/// Progress events emitted during the send (serving) lifecycle.
#[derive(Debug, Clone, PartialEq)]
pub enum SendProgress {
    /// Incremental progress when hashing and importing a file into the local blob store.
    Importing {
        file_name: String,
        bytes_done: u64,
        bytes_total: u64,
    },
    /// All files have been imported and packed into an Iroh collection.
    ImportDone { total_size: u64 },
    /// Binding the local QUIC endpoint and connecting to the relay network.
    StartingEndpoint,
    /// The ticket is ready and the node is actively serving blobs.
    Sharing { ticket: String },
    /// A fatal error occurred during the send workflow.
    Failed { error: String },
}

/// Progress events emitted during the receive (download) lifecycle.
#[derive(Debug, Clone, PartialEq)]
pub enum ReceiveProgress {
    /// Attempting to establish a connection to the peer via relay or direct QUIC.
    Connecting,
    /// Successfully established a QUIC connection with the remote peer.
    Connected,
    /// Retrieving the hash sequence and metadata for the collection.
    RetrievingMetadata,
    /// Downloading blob data over the network.
    Downloading {
        bytes_downloaded: u64,
        total_bytes: u64,
        percentage: f64,
    },
    /// All raw blob data has finished downloading into the local store.
    DownloadDone { total_bytes: u64 },
    /// Exporting a specific file from the blob store onto the filesystem.
    Exporting {
        file_name: String,
        bytes_exported: u64,
        bytes_total: u64,
    },
    /// The entire transfer and export operation has completed successfully.
    Finished {
        total_files: u64,
        total_bytes: u64,
        exported_paths: Vec<String>,
    },
    /// A fatal error or user cancellation occurred during the receive workflow.
    Failed { error: String },
}

// ─── Progress Reporter Traits ────────────────────────────────────

/// Trait abstracting progress reporting during file import and sending.
pub trait SendProgressReporter: Send + Sync + 'static {
    fn report(&self, progress: SendProgress);
}

impl SendProgressReporter for StreamSink<SendProgress> {
    fn report(&self, progress: SendProgress) {
        let _ = self.add(progress);
    }
}

/// Trait abstracting progress reporting during downloading and export.
pub trait ReceiveProgressReporter: Send + Sync + 'static {
    fn report(&self, progress: ReceiveProgress);
}

impl ReceiveProgressReporter for StreamSink<ReceiveProgress> {
    fn report(&self, progress: ReceiveProgress) {
        let _ = self.add(progress);
    }
}

// ─── Session State ───────────────────────────────────────────────

/// Internal state representing an active send session.
struct SendSession {
    router: Router,
    /// Retained to prevent Iroh blob garbage collection while sharing.
    #[allow(dead_code)]
    temp_tag: TempTag,
    blobs_data_dir: PathBuf,
}

/// Internal state representing an active receive session.
struct ReceiveSession {
    cancel_tx: oneshot::Sender<()>,
}

static ACTIVE_SEND: Lazy<Mutex<Option<SendSession>>> = Lazy::new(|| Mutex::new(None));
static SEND_START_LOCK: tokio::sync::Mutex<()> = tokio::sync::Mutex::const_new(());
static RECEIVE_START_LOCK: tokio::sync::Mutex<()> = tokio::sync::Mutex::const_new(());
static SEND_CANCEL: Lazy<watch::Sender<()>> = Lazy::new(|| watch::channel(()).0);

static ACTIVE_RECEIVE: Lazy<Mutex<Option<ReceiveSession>>> = Lazy::new(|| Mutex::new(None));

// ─── Public API ──────────────────────────────────────────────────

/// Start sharing a file or directory over Iroh P2P.
///
/// Streams [`SendProgress`] updates to Dart via `sink`.
pub async fn start_send(path: String, temp_dir: String, sink: StreamSink<SendProgress>) {
    if let Err(e) = start_send_inner(path, temp_dir, &sink).await {
        let _ = sink.add(SendProgress::Failed {
            error: e.to_string(),
        });
    }
}

/// Stop an active send session, shutdown the router, and reclaim temporary blob storage.
pub fn stop_send() -> anyhow::Result<()> {
    let mut guard = ACTIVE_SEND.lock().unwrap();
    SEND_CANCEL.send_replace(());
    if let Some(session) = guard.take() {
        info!(
            "[SEND] Stopping active send session, cleaning up {}",
            session.blobs_data_dir.display()
        );
        let cleanup_fut = async move {
            let _ = session.router.shutdown().await;
            drop(session.temp_tag);
            let _ = tokio::fs::remove_dir_all(&session.blobs_data_dir).await;
            debug!("[SEND] Send session cleanup completed successfully");
        };

        if let Ok(handle) = tokio::runtime::Handle::try_current() {
            handle.spawn(cleanup_fut);
        } else {
            std::thread::spawn(move || {
                if let Ok(rt) = tokio::runtime::Builder::new_current_thread()
                    .enable_all()
                    .build()
                {
                    rt.block_on(cleanup_fut);
                }
            });
        }
    }
    Ok(())
}

/// Start receiving (downloading) data using a Sendme ticket string.
///
/// Streams [`ReceiveProgress`] updates to Dart via `sink`.
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

/// Cancel an active receive session and abort in-flight transfers.
pub fn cancel_receive() -> anyhow::Result<()> {
    let mut guard = ACTIVE_RECEIVE.lock().unwrap();
    if let Some(session) = guard.take() {
        info!("[RECV] Cancelling active receive session");
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

    let _start_guard = SEND_START_LOCK.lock().await;
    // 1. Clean up any existing send session
    let _ = stop_send();
    let mut cancelled = SEND_CANCEL.subscribe();

    reporter.report(SendProgress::StartingEndpoint);

    // 2. Validate input path
    anyhow::ensure!(!path_str.is_empty(), "Target path cannot be empty");
    let path = tokio::fs::canonicalize(&path_str).await?;
    anyhow::ensure!(path.parent().is_some(), "Cannot share root directory");
    anyhow::ensure!(
        path.exists(),
        "Target path '{}' does not exist",
        path.display()
    );

    // 3. Generate a fresh secret key and bind endpoint
    let secret_key = iroh::SecretKey::generate();
    info!("[SEND] Generated secret key, binding endpoint...");

    let endpoint = match Endpoint::builder(iroh::endpoint::presets::N0)
        .alpns(vec![ALPN.to_vec()])
        .secret_key(secret_key)
        .relay_mode(RelayMode::Default)
        .bind()
        .await
    {
        Ok(ep) => {
            info!("[SEND] Endpoint bound. ID: {}", ep.id());
            ep
        }
        Err(e) => {
            error!("[SEND] Failed to bind endpoint: {}", e);
            return Err(e.into());
        }
    };

    // 4. Set up temporary blobs directory
    let suffix: [u8; 16] = rand::random();
    let blobs_data_dir =
        PathBuf::from(&temp_dir_str).join(format!(".sendme-send-{}", hex::encode(suffix)));

    if let Err(e) = tokio::fs::create_dir_all(&blobs_data_dir).await {
        error!(
            "[SEND] Failed to create blob directory {}: {}",
            blobs_data_dir.display(),
            e
        );
        endpoint.close().await;
        return Err(e.into());
    }
    info!("[SEND] Blob store dir: {}", blobs_data_dir.display());

    let store = match FsStore::load(&blobs_data_dir).await {
        Ok(s) => s,
        Err(e) => {
            error!("[SEND] FsStore::load failed: {}", e);
            endpoint.close().await;
            let _ = tokio::fs::remove_dir_all(&blobs_data_dir).await;
            return Err(e.into());
        }
    };

    let blobs = iroh_blobs::BlobsProtocol::new(&store, None);

    // 5. Import the file or directory
    info!("[SEND] Importing path: {}", path.display());
    let imported = tokio::select! {
        biased;
        _ = cancelled.changed() => Err(anyhow::anyhow!("Send operation cancelled by user")),
        result = import_with_progress(path, &store, reporter) => result,
    };
    let (temp_tag, size, _collection) = match imported {
        Ok(res) => res,
        Err(e) => {
            error!("[SEND] Import failed: {}", e);
            let _ = store.shutdown().await;
            endpoint.close().await;
            let _ = tokio::fs::remove_dir_all(&blobs_data_dir).await;
            return Err(e);
        }
    };
    info!(
        "[SEND] Import done. Hash={}, size={}",
        temp_tag.hash(),
        size
    );

    // 6. Set up the protocol router to serve blobs
    let router = Router::builder(endpoint).accept(ALPN, blobs).spawn();
    info!("[SEND] Router spawned, waiting for relay online...");

    // 7. Wait for endpoint to come online (relay connection)
    let ep = router.endpoint().clone();
    let online = tokio::select! {
        biased;
        _ = cancelled.changed() => {
            let _ = router.shutdown().await;
            drop(temp_tag);
            let _ = tokio::fs::remove_dir_all(&blobs_data_dir).await;
            anyhow::bail!("Send operation cancelled by user");
        }
        result = tokio::time::timeout(Duration::from_secs(30), ep.online()) => result,
    };
    match online {
        Ok(_) => info!("[SEND] Endpoint online (relay connected)"),
        Err(_) => warn!("[SEND] Timeout waiting for relay — using local addresses only"),
    }

    // 8. Generate share ticket
    let addr = router.endpoint().addr();
    info!("[SEND] Node addr: {:?}", addr);
    let hash = temp_tag.hash();
    let ticket = BlobTicket::new(addr, hash, BlobFormat::HashSeq);
    let ticket_str = ticket.to_string();
    info!("[SEND] Ticket generated: {}", ticket_str);

    // 9. Store session state
    let session = SendSession {
        router,
        temp_tag,
        blobs_data_dir,
    };
    // Stop and activation share the same lock, so a stopped preparation cannot
    // publish a new session after stop_send has returned.
    let cancelled_before_activation = {
        let mut active = ACTIVE_SEND.lock().unwrap();
        if cancelled.has_changed().unwrap_or(true) {
            Some(session)
        } else {
            *active = Some(session);
            None
        }
    };
    if let Some(session) = cancelled_before_activation {
        let _ = session.router.shutdown().await;
        drop(session.temp_tag);
        let _ = tokio::fs::remove_dir_all(session.blobs_data_dir).await;
        anyhow::bail!("Send operation cancelled by user");
    }

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

    // Cancellation precedes serialization so replacement requests interrupt the
    // previous transfer, but cannot race its store teardown or session clearing.
    let _ = cancel_receive();
    let _start_guard = RECEIVE_START_LOCK.lock().await;

    // 2. Parse the ticket
    let ticket = BlobTicket::from_str(&ticket_str).map_err(|e| {
        error!("[RECV] Invalid ticket: {}", e);
        e
    })?;
    anyhow::ensure!(
        ticket.format() == BlobFormat::HashSeq,
        "Ticket must reference a collection"
    );
    let addr = ticket.addr().clone();
    info!(
        "[RECV] Ticket parsed. Hash={}, format={:?}",
        ticket.hash(),
        ticket.format()
    );
    info!(
        "[RECV] Peer addr: relay_urls={:?}, ip_addrs={:?}",
        ticket.addr().relay_urls().collect::<Vec<_>>(),
        ticket.addr().ip_addrs().collect::<Vec<_>>()
    );

    // 3. Create a cancellation channel and register session
    let (cancel_tx, mut cancel_rx) = oneshot::channel::<()>();
    *ACTIVE_RECEIVE.lock().unwrap() = Some(ReceiveSession { cancel_tx });

    reporter.report(ReceiveProgress::Connecting);

    // 4. Create receiver endpoint
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

    let endpoint = match builder.bind().await {
        Ok(ep) => ep,
        Err(e) => {
            error!("[RECV] Endpoint bind failed: {}", e);
            *ACTIVE_RECEIVE.lock().unwrap() = None;
            return Err(e.into());
        }
    };
    info!("[RECV] Receiver endpoint bound. ID: {}", endpoint.id());

    // 5. Set up temporary blob store
    let dir_name = format!(".sendme-recv-{}", hex::encode(rand::random::<[u8; 16]>()));
    let iroh_data_dir = PathBuf::from(&temp_dir_str).join(&dir_name);
    if let Err(e) = tokio::fs::create_dir_all(&iroh_data_dir).await {
        error!(
            "[RECV] Failed to create blob directory {}: {}",
            iroh_data_dir.display(),
            e
        );
        endpoint.close().await;
        *ACTIVE_RECEIVE.lock().unwrap() = None;
        return Err(e.into());
    }
    info!("[RECV] Blob store dir: {}", iroh_data_dir.display());

    let db = match FsStore::load(&iroh_data_dir).await {
        Ok(store) => store,
        Err(e) => {
            error!("[RECV] FsStore::load failed: {}", e);
            endpoint.close().await;
            let _ = tokio::fs::remove_dir_all(&iroh_data_dir).await;
            *ACTIVE_RECEIVE.lock().unwrap() = None;
            return Err(e.into());
        }
    };
    let db_clone = db.clone();

    // 6. Run the receive with cancellation support
    let receive_fut = async {
        let hash_and_format = ticket.hash_and_format();
        let local = db.remote().local(hash_and_format).await?;
        info!("[RECV] Local state: is_complete={}", local.is_complete());

        let (_stats, _total_files, payload_size) = if !local.is_complete() {
            info!("[RECV] Connecting to sender at {:?}...", addr);
            let connection = endpoint
                .connect(addr, iroh_blobs::protocol::ALPN)
                .await
                .map_err(|e| {
                    error!("[RECV] QUIC connect failed: {}", e);
                    e
                })?;
            info!("[RECV] QUIC connection established!");
            reporter.report(ReceiveProgress::Connected);
            reporter.report(ReceiveProgress::RetrievingMetadata);

            info!("[RECV] Fetching hash sequence and sizes...");
            let (_hash_seq, sizes) = iroh_blobs::get::request::get_hash_seq_and_sizes(
                &connection,
                &hash_and_format.hash,
                1024 * 1024 * 32,
                None,
            )
            .await
            .map_err(|e| {
                error!("[RECV] get_hash_seq_and_sizes failed: {}", e);
                e
            })?;

            let total_size = sum_sizes(sizes.iter().copied())?;
            let payload_size = sum_sizes(sizes.iter().skip(1).copied())?;
            let total_files = sizes.len().saturating_sub(1) as u64;
            info!(
                "[RECV] Metadata: {} files, total_size={}, payload_size={}",
                total_files, total_size, payload_size
            );

            let get = db.remote().execute_get(connection, local.missing());
            let mut stream = get.stream();
            let mut stats = None;
            let mut last_pct = 0.0f64;

            while let Some(item) = stream.next().await {
                match item {
                    GetProgressItem::Progress(offset) => {
                        let pct = if total_size > 0 {
                            (offset as f64 / total_size as f64) * 100.0
                        } else {
                            0.0
                        };
                        if pct >= last_pct + 5.0 || offset == total_size {
                            debug!(
                                "[RECV] Download progress: {:.1}% ({}/{})",
                                pct, offset, total_size
                            );
                            last_pct = pct;
                        }
                        reporter.report(ReceiveProgress::Downloading {
                            bytes_downloaded: offset,
                            total_bytes: total_size,
                            percentage: pct.min(100.0),
                        });
                    }
                    GetProgressItem::Done(value) => {
                        info!("[RECV] Download done: {:?}", value);
                        stats = Some(value);
                        break;
                    }
                    GetProgressItem::Error(cause) => {
                        error!("[RECV] Download stream error: {}", cause);
                        anyhow::bail!("Download error: {}", cause);
                    }
                }
            }
            let stats =
                stats.ok_or_else(|| anyhow::anyhow!("Download stream ended before completion"))?;
            reporter.report(ReceiveProgress::DownloadDone {
                total_bytes: total_size,
            });
            (stats, total_files, payload_size)
        } else {
            info!("[RECV] Already fully downloaded locally");
            let total_files = local.children().unwrap_or(1).saturating_sub(1);
            (iroh_blobs::get::Stats::default(), total_files, 0)
        };

        info!("[RECV] Loading collection from store...");
        let collection = Collection::load(hash_and_format.hash, db.as_ref())
            .await
            .map_err(|e| {
                error!("[RECV] Collection::load failed: {}", e);
                e
            })?;
        info!("[RECV] Collection loaded: {} entries", collection.len());

        reporter.report(ReceiveProgress::Exporting {
            file_name: String::new(),
            bytes_exported: 0,
            bytes_total: payload_size,
        });

        info!("[RECV] Exporting to: {}", destination_dir_str);
        let total_files = collection.len() as u64;
        let (exported_paths, payload_size) =
            export_with_progress(&db, collection, &destination_dir_str, reporter)
                .await
                .map_err(|e| {
                    error!("[RECV] Export failed: {}", e);
                    e
                })?;

        info!(
            "[RECV] Export complete! total_files={}, payload_size={}",
            total_files, payload_size
        );
        anyhow::Ok((total_files, payload_size, exported_paths))
    };

    let result = tokio::select! {
        biased;
        _ = &mut cancel_rx => {
            warn!("[RECV] Cancelled by user");
            endpoint.close().await;
            Err(anyhow::anyhow!("Receive operation cancelled by user"))
        }
        res = receive_fut => {
            endpoint.close().await;
            res
        }
    };

    // Teardown store and reclaim temporary directory
    let _ = db_clone.shutdown().await;
    drop(db_clone);
    let _ = tokio::fs::remove_dir_all(&iroh_data_dir).await;
    *ACTIVE_RECEIVE.lock().unwrap() = None;

    match result {
        Ok((files, bytes, exported_paths)) => {
            reporter.report(ReceiveProgress::Finished {
                total_files: files,
                total_bytes: bytes,
                exported_paths,
            });
        }
        Err(e) => {
            error!("[RECV] Failed: {}", e);
            reporter.report(ReceiveProgress::Failed {
                error: e.to_string(),
            });
        }
    }

    Ok(())
}

// ─── Import Helpers ──────────────────────────────────────────────

/// Traverses the given path, adds all discovered files to the local blob store,
/// and builds a collection root [`TempTag`].
async fn import_with_progress(
    path: PathBuf,
    db: &FsStore,
    reporter: &impl SendProgressReporter,
) -> anyhow::Result<(TempTag, u64, Collection)> {
    let path = tokio::fs::canonicalize(path).await?;
    info!(
        "[SEND] import_with_progress: target path={}",
        path.display()
    );
    anyhow::ensure!(path.exists(), "path '{}' does not exist", path.display());
    anyhow::ensure!(path.parent().is_some(), "Cannot share root directory");

    let is_dir = path.is_dir();
    let is_file = path.is_file();
    anyhow::ensure!(
        is_file || is_dir,
        "path '{}' is neither a regular file nor a directory",
        path.display()
    );
    info!(
        "[SEND] path metadata: is_dir={}, is_file={}",
        is_dir, is_file
    );

    let root = path.parent().unwrap_or_else(|| Path::new("/"));
    info!("[SEND] base root for relative paths: {}", root.display());

    // Collect all files to import
    let mut files = Vec::new();
    let mut walk_error = None;
    if is_file {
        let relative = path.strip_prefix(root)?;
        let name = canonicalized_path_to_string(relative, true)?;
        info!(
            "[SEND] Single file to import: name='{}', path='{}'",
            name,
            path.display()
        );
        files.push((name, path.clone()));
    } else {
        info!("[SEND] Walking directory: {}", path.display());
        for entry in walkdir::WalkDir::new(&path).follow_links(false) {
            match entry {
                Ok(e) => {
                    let entry_is_file = e.file_type().is_file();
                    debug!(
                        "[SEND] Walkdir discovered: path='{}', is_file={}",
                        e.path().display(),
                        entry_is_file
                    );
                    if entry_is_file {
                        let p = e.into_path();
                        let relative = p.strip_prefix(root)?;
                        let name = canonicalized_path_to_string(relative, true)?;
                        files.push((name, p));
                    }
                }
                Err(err) => {
                    warn!(
                        "[SEND] Walkdir error on entry in '{}': {}",
                        path.display(),
                        err
                    );
                    if walk_error.is_none() {
                        walk_error = Some(err.to_string());
                    }
                }
            }
        }
    }

    info!("[SEND] Total files collected for import: {}", files.len());

    if let Some(err) = walk_error {
        anyhow::bail!("Cannot read entire folder {}: {}", path.display(), err);
    }
    anyhow::ensure!(
        !files.is_empty(),
        "Folder '{}' contains no files to share.",
        path.display()
    );

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
    let total_size = sum_sizes(names_and_tags.iter().map(|(_, _, size)| *size))?;

    // Build the collection from sorted (name, hash) pairs
    let (collection, tags) = names_and_tags
        .into_iter()
        .map(|(name, tag, _)| ((name, tag.hash()), tag))
        .unzip::<_, _, Collection, Vec<_>>();

    // Store collection in blob store; returns TempTag protecting the HashSeq
    let temp_tag = collection.clone().store(db.as_ref()).await?;
    drop(tags);

    reporter.report(SendProgress::ImportDone { total_size });
    Ok((temp_tag, total_size, collection))
}

// ─── Export Helpers ──────────────────────────────────────────────

/// Exports all blobs in the given collection into the target destination directory.
async fn export_with_progress(
    db: &FsStore,
    collection: Collection,
    destination_dir: &str,
    reporter: &impl ReceiveProgressReporter,
) -> anyhow::Result<(Vec<String>, u64)> {
    tokio::fs::create_dir_all(destination_dir).await?;
    let root = tokio::fs::canonicalize(destination_dir).await?;
    let mut exported_paths = Vec::new();
    let mut total_bytes = 0u64;

    for (name, hash) in collection.iter() {
        let target = get_export_path(&root, name)?;
        // Validate filesystem components too: lexical checks alone do not stop
        // a pre-existing symlink from redirecting writes outside the destination.
        let relative_parent = target.parent().unwrap().strip_prefix(&root)?;
        let mut parent = root.clone();
        for component in relative_parent.components() {
            parent.push(component);
            match tokio::fs::create_dir(&parent).await {
                Ok(()) => {}
                Err(e) if e.kind() == std::io::ErrorKind::AlreadyExists => {}
                Err(e) => return Err(e.into()),
            }
            let metadata = tokio::fs::symlink_metadata(&parent).await?;
            anyhow::ensure!(
                metadata.is_dir() && !metadata.is_symlink(),
                "Export parent is not a regular directory: {}",
                parent.display()
            );
        }

        // create_new atomically refuses existing files and dangling symlinks.
        let mut output = tokio::fs::OpenOptions::new()
            .write(true)
            .create_new(true)
            .open(&target)
            .await?;
        let mut pending = PendingExport(Some(target.clone()));
        reporter.report(ReceiveProgress::Exporting {
            file_name: name.clone(),
            bytes_exported: 0,
            bytes_total: 0,
        });
        let mut reader = db.reader(*hash);
        let copied = tokio::io::copy(&mut reader, &mut output).await?;
        use tokio::io::AsyncWriteExt;
        output.flush().await?;
        drop(output);
        pending.0 = None;
        total_bytes = sum_sizes([total_bytes, copied].into_iter())?;
        reporter.report(ReceiveProgress::Exporting {
            file_name: name.clone(),
            bytes_exported: copied,
            bytes_total: copied,
        });
        exported_paths.push(target.to_string_lossy().to_string());
    }

    Ok((exported_paths, total_bytes))
}

/// Remove a partial output if copying fails or its future is cancelled.
struct PendingExport(Option<PathBuf>);

impl Drop for PendingExport {
    fn drop(&mut self) {
        if let Some(path) = &self.0 {
            let _ = std::fs::remove_file(path);
        }
    }
}

fn sum_sizes(mut sizes: impl Iterator<Item = u64>) -> anyhow::Result<u64> {
    sizes.try_fold(0u64, |total, size| {
        total
            .checked_add(size)
            .ok_or_else(|| anyhow::anyhow!("Transfer size exceeds supported range"))
    })
}

// ─── Path Utilities ──────────────────────────────────────────────

/// Validates an individual path component of an exported file.
///
/// Disallows directory traversal sequences (`..`, `.`), empty components,
/// path separators, and null bytes.
fn validate_path_component(component: &str) -> anyhow::Result<()> {
    anyhow::ensure!(!component.is_empty(), "Path component cannot be empty");
    anyhow::ensure!(
        component != "." && component != "..",
        "Path components cannot contain relative traversal segments ('.' or '..')"
    );
    anyhow::ensure!(
        !component.contains('/')
            && !component.contains('\\')
            && !component.contains('\0')
            && !component.contains(':'),
        "Path component cannot contain path separators or null bytes"
    );
    Ok(())
}

/// Constructs a safe export destination path under the given root directory.
///
/// Prevents path traversal vulnerabilities by validating every component
/// and verifying that the final path resides strictly within the root destination directory.
fn get_export_path(root: &Path, name: &str) -> anyhow::Result<PathBuf> {
    anyhow::ensure!(!name.is_empty(), "Export file name cannot be empty");
    let parts = name.split('/');
    let mut path = root.to_path_buf();
    for part in parts {
        validate_path_component(part)?;
        path.push(part);
    }

    // Guard against directory traversal
    if !path.starts_with(root) {
        anyhow::bail!("Path traversal security violation detected: '{}'", name);
    }

    Ok(path)
}

/// Converts a `Path` into a standardized, forward-slash separated relative path string.
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
                    None => return Some(Err(anyhow::anyhow!("Invalid unicode character in path"))),
                };

                if validate_path_component(c).is_ok() {
                    Some(Ok(c))
                } else {
                    Some(Err(anyhow::anyhow!(
                        "Invalid character in path component {:?}",
                        c
                    )))
                }
            }
            Component::RootDir => {
                if must_be_relative {
                    Some(Err(anyhow::anyhow!("Invalid path component {:?}", c)))
                } else {
                    path_str.push('/');
                    None
                }
            }
            _ => Some(Err(anyhow::anyhow!(
                "Invalid relative path component {:?}",
                c
            ))),
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

    static TEST_LOCK: Lazy<tokio::sync::Mutex<()>> = Lazy::new(|| tokio::sync::Mutex::new(()));

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
        let _guard = TEST_LOCK.lock().await;
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
        assert!(
            received_file_path.exists(),
            "Received file should exist at path"
        );

        let received_content = tokio::fs::read(&received_file_path).await?;
        assert_eq!(received_content, file_content, "Content should match");

        // Ensure transfer events show finished status
        let mut finished = false;
        {
            let events = receive_events.lock().unwrap();
            for event in events.iter() {
                if let ReceiveProgress::Finished {
                    total_files,
                    total_bytes,
                    ..
                } = event
                {
                    assert_eq!(*total_files, 1);
                    assert_eq!(*total_bytes, file_content.len() as u64);
                    finished = true;
                }
            }
        }
        assert!(finished, "Receive should finish successfully");

        // Stop active send session and verify cleanup
        stop_send()?;
        tokio::fs::remove_dir_all(&temp_base).await?;

        Ok(())
    }

    #[tokio::test]
    async fn test_send_receive_folder_local() -> anyhow::Result<()> {
        let _guard = TEST_LOCK.lock().await;
        let temp_base =
            std::env::temp_dir().join(format!("sendme-folder-test-{}", rand::random::<u32>()));
        tokio::fs::create_dir_all(&temp_base).await?;

        let source_root = temp_base.join("source");
        let shared_folder = source_root.join("my_shared_project");
        let sub_folder = shared_folder.join("nested").join("docs");
        let temp_dir = temp_base.join("temp");
        let dest_dir = temp_base.join("dest");

        tokio::fs::create_dir_all(&sub_folder).await?;
        tokio::fs::create_dir_all(&temp_dir).await?;
        tokio::fs::create_dir_all(&dest_dir).await?;

        // Create multiple nested test files
        let file1_path = shared_folder.join("readme.md");
        let file1_content = b"# Shared Project\nThis is a root folder file.";
        tokio::fs::write(&file1_path, file1_content).await?;

        let file2_path = sub_folder.join("config.json");
        let file2_content = br#"{"status": "ok", "nested": true}"#;
        tokio::fs::write(&file2_path, file2_content).await?;

        let send_events = Arc::new(Mutex::new(Vec::new()));
        let send_reporter = TestSendReporter {
            events: send_events.clone(),
        };

        // Test sending with trailing slash to test path normalization
        let send_path_str = format!("{}/", shared_folder.to_string_lossy());
        start_send_inner(
            send_path_str,
            temp_dir.to_string_lossy().to_string(),
            &send_reporter,
        )
        .await?;

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

        // Verify folder hierarchy in dest_dir
        let received_file1 = dest_dir.join("my_shared_project").join("readme.md");
        let received_file2 = dest_dir
            .join("my_shared_project")
            .join("nested")
            .join("docs")
            .join("config.json");

        assert!(
            received_file1.exists(),
            "Received file1 should exist at {}",
            received_file1.display()
        );
        assert!(
            received_file2.exists(),
            "Received file2 should exist at {}",
            received_file2.display()
        );

        let read_content1 = tokio::fs::read(&received_file1).await?;
        let read_content2 = tokio::fs::read(&received_file2).await?;

        assert_eq!(read_content1, file1_content);
        assert_eq!(read_content2, file2_content);

        assert!(receive_events
            .lock()
            .unwrap()
            .iter()
            .any(|event| matches!(event,
            ReceiveProgress::Finished { total_files: 2, total_bytes, .. }
            if *total_bytes == (file1_content.len() + file2_content.len()) as u64)));

        stop_send()?;
        tokio::fs::remove_dir_all(&temp_base).await?;

        Ok(())
    }

    #[test]
    fn test_path_validation_and_security() {
        // Valid component
        assert!(validate_path_component("hello.txt").is_ok());
        assert!(validate_path_component("my_folder").is_ok());

        // Invalid components
        assert!(validate_path_component("..").is_err());
        assert!(validate_path_component(".").is_err());
        assert!(validate_path_component("").is_err());
        assert!(validate_path_component("sub/dir").is_err());
        assert!(validate_path_component("sub\\dir").is_err());
        assert!(validate_path_component("null\0byte").is_err());

        // Path export tests
        let root = Path::new("/downloads");
        let safe_path = get_export_path(root, "docs/report.pdf").unwrap();
        assert_eq!(safe_path, PathBuf::from("/downloads/docs/report.pdf"));

        // Path traversal attempts must fail
        assert!(get_export_path(root, "../secret.txt").is_err());
        assert!(get_export_path(root, "docs/../../secret.txt").is_err());
        assert!(get_export_path(root, "").is_err());
    }

    #[tokio::test]
    async fn test_stop_send_cleanup() -> anyhow::Result<()> {
        let _guard = TEST_LOCK.lock().await;
        let temp_base =
            std::env::temp_dir().join(format!("sendme-cleanup-test-{}", rand::random::<u32>()));
        let temp_dir = temp_base.join("temp");
        let source_dir = temp_base.join("source");

        tokio::fs::create_dir_all(&temp_dir).await?;
        tokio::fs::create_dir_all(&source_dir).await?;

        let test_file = source_dir.join("sample.txt");
        tokio::fs::write(&test_file, b"sample content for cleanup test").await?;

        let send_events = Arc::new(Mutex::new(Vec::new()));
        let send_reporter = TestSendReporter {
            events: send_events.clone(),
        };

        start_send_inner(
            test_file.to_string_lossy().to_string(),
            temp_dir.to_string_lossy().to_string(),
            &send_reporter,
        )
        .await?;

        // Verify active send session is registered
        {
            let guard = ACTIVE_SEND.lock().unwrap();
            assert!(
                guard.is_some(),
                "ACTIVE_SEND should contain an active session"
            );
        }

        // Call stop_send
        stop_send()?;

        // Wait briefly for async cleanup task to complete
        tokio::time::sleep(Duration::from_millis(200)).await;

        // Verify ACTIVE_SEND is now None
        {
            let guard = ACTIVE_SEND.lock().unwrap();
            assert!(
                guard.is_none(),
                "ACTIVE_SEND should be None after stop_send"
            );
        }

        tokio::fs::remove_dir_all(&temp_base).await?;
        Ok(())
    }

    #[tokio::test]
    async fn test_send_nonexistent_path() -> anyhow::Result<()> {
        let _guard = TEST_LOCK.lock().await;
        let send_events = Arc::new(Mutex::new(Vec::new()));
        let send_reporter = TestSendReporter {
            events: send_events.clone(),
        };

        let res = start_send_inner(
            "/nonexistent/path/that/does/not/exist.xyz".to_string(),
            std::env::temp_dir().to_string_lossy().to_string(),
            &send_reporter,
        )
        .await;

        assert!(res.is_err(), "Should return error for non-existent path");
        Ok(())
    }

    #[tokio::test]
    async fn test_receive_invalid_ticket() -> anyhow::Result<()> {
        let _guard = TEST_LOCK.lock().await;
        let receive_events = Arc::new(Mutex::new(Vec::new()));
        let receive_reporter = TestReceiveReporter {
            events: receive_events.clone(),
        };

        let res = start_receive_inner(
            "not-a-valid-iroh-ticket".to_string(),
            std::env::temp_dir().to_string_lossy().to_string(),
            std::env::temp_dir().to_string_lossy().to_string(),
            &receive_reporter,
        )
        .await;

        assert!(res.is_err(), "Should return error for invalid ticket");
        // Verify active receive session was cleaned up
        let guard = ACTIVE_RECEIVE.lock().unwrap();
        assert!(guard.is_none(), "ACTIVE_RECEIVE should be None");
        Ok(())
    }

    #[test]
    fn test_root_path_parent_resolution() {
        let root_path = Path::new("/");
        let root = root_path.parent().unwrap_or_else(|| Path::new("/"));
        assert_eq!(root, Path::new("/"));
    }
    #[test]
    fn test_size_overflow() {
        assert_eq!(sum_sizes([10, 20].into_iter()).unwrap(), 30);
        assert!(sum_sizes([u64::MAX, 1].into_iter()).is_err());
    }

    #[tokio::test]
    async fn test_cancel_receive_reclaims_store() -> anyhow::Result<()> {
        let _guard = TEST_LOCK.lock().await;
        struct CancelOnConnect;
        impl ReceiveProgressReporter for CancelOnConnect {
            fn report(&self, progress: ReceiveProgress) {
                if matches!(progress, ReceiveProgress::Connecting) {
                    cancel_receive().unwrap();
                }
            }
        }
        let base = std::env::temp_dir().join(format!("sendme-cancel-{}", rand::random::<u64>()));
        tokio::fs::create_dir_all(&base).await?;
        let ticket = BlobTicket::new(
            iroh::SecretKey::generate().public().into(),
            iroh_blobs::Hash::new(b"test"),
            BlobFormat::HashSeq,
        );
        tokio::time::timeout(
            Duration::from_secs(10),
            start_receive_inner(
                ticket.to_string(),
                base.to_string_lossy().into_owned(),
                base.join("dest").to_string_lossy().into_owned(),
                &CancelOnConnect,
            ),
        )
        .await??;
        assert!(ACTIVE_RECEIVE.lock().unwrap().is_none());
        assert!(tokio::fs::read_dir(&base)
            .await?
            .next_entry()
            .await?
            .is_none());
        tokio::fs::remove_dir_all(base).await?;
        Ok(())
    }

    #[tokio::test]
    async fn test_stop_send_during_preparation() -> anyhow::Result<()> {
        let _guard = TEST_LOCK.lock().await;
        struct StopOnStart;
        impl SendProgressReporter for StopOnStart {
            fn report(&self, progress: SendProgress) {
                if matches!(progress, SendProgress::StartingEndpoint) {
                    stop_send().unwrap();
                }
                assert!(!matches!(progress, SendProgress::Sharing { .. }));
            }
        }
        let base = std::env::temp_dir().join(format!("sendme-stop-{}", rand::random::<u64>()));
        tokio::fs::create_dir_all(&base).await?;
        let source = base.join("source.txt");
        tokio::fs::write(&source, b"test").await?;
        let result = start_send_inner(
            source.to_string_lossy().into_owned(),
            base.to_string_lossy().into_owned(),
            &StopOnStart,
        )
        .await;
        assert!(result.is_err());
        assert!(ACTIVE_SEND.lock().unwrap().is_none());
        assert_eq!(std::fs::read_dir(&base)?.count(), 1);
        tokio::fs::remove_dir_all(base).await?;
        Ok(())
    }

    #[tokio::test]
    async fn test_export_refuses_overwrite_and_removes_failed_output() -> anyhow::Result<()> {
        let base = std::env::temp_dir().join(format!("sendme-export-{}", rand::random::<u64>()));
        let db = FsStore::load(base.join("store")).await?;
        let dest = base.join("dest");
        tokio::fs::create_dir_all(&dest).await?;
        let tag = db.add_slice(b"new content").await?;
        let reporter = TestReceiveReporter {
            events: Arc::new(Mutex::new(Vec::new())),
        };
        let collection: Collection = [("file.txt".to_string(), tag.hash)].into_iter().collect();
        tokio::fs::write(dest.join("file.txt"), b"existing").await?;
        assert!(
            export_with_progress(&db, collection, dest.to_str().unwrap(), &reporter)
                .await
                .is_err()
        );
        assert_eq!(tokio::fs::read(dest.join("file.txt")).await?, b"existing");
        let missing: Collection = [("missing.txt".to_string(), iroh_blobs::Hash::new(b"missing"))]
            .into_iter()
            .collect();
        assert!(
            export_with_progress(&db, missing, dest.to_str().unwrap(), &reporter)
                .await
                .is_err()
        );
        assert!(!dest.join("missing.txt").exists());
        db.shutdown().await?;
        tokio::fs::remove_dir_all(base).await?;
        Ok(())
    }

    #[cfg(unix)]
    #[tokio::test]
    async fn test_export_rejects_symlinks() -> anyhow::Result<()> {
        use std::os::unix::fs::symlink;
        let base = std::env::temp_dir().join(format!("sendme-symlink-{}", rand::random::<u64>()));
        let db = FsStore::load(base.join("store")).await?;
        let dest = base.join("dest");
        let outside = base.join("outside");
        tokio::fs::create_dir_all(&dest).await?;
        tokio::fs::create_dir_all(&outside).await?;
        symlink(&outside, dest.join("escape"))?;
        symlink(outside.join("missing.txt"), dest.join("dangling.txt"))?;
        let tag = db.add_slice(b"content").await?;
        let reporter = TestReceiveReporter {
            events: Arc::new(Mutex::new(Vec::new())),
        };
        for name in [
            "escape/file.txt",
            "dangling.txt",
            "../outside/file.txt",
            "C:escape",
        ] {
            let collection = [(name.to_string(), tag.hash)].into_iter().collect();
            assert!(
                export_with_progress(&db, collection, dest.to_str().unwrap(), &reporter)
                    .await
                    .is_err(),
                "{name}"
            );
        }
        assert_eq!(std::fs::read_dir(&outside)?.count(), 0);
        db.shutdown().await?;
        tokio::fs::remove_dir_all(base).await?;
        Ok(())
    }
}
