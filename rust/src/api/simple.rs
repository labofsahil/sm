use once_cell::sync::Lazy;
use parking_lot::RwLock;
use std::collections::VecDeque;
use tracing_subscriber::{fmt, layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};

const MAX_LOG_LINES: usize = 500;
static LOG_BUFFER: Lazy<RwLock<VecDeque<String>>> =
    Lazy::new(|| RwLock::new(VecDeque::with_capacity(MAX_LOG_LINES)));

struct RingBufferLayer;
impl<S: tracing::Subscriber> tracing_subscriber::Layer<S> for RingBufferLayer {
    fn on_event(&self, event: &tracing::Event<'_>, _ctx: tracing_subscriber::layer::Context<'_, S>) {
        let meta = event.metadata();
        let mut visitor = StringVisitor(String::new());
        event.record(&mut visitor);
        let line = format!("[{}][{}] {}", meta.level(), meta.target(), visitor.0);
        let mut buf = LOG_BUFFER.write();
        if buf.len() >= MAX_LOG_LINES { buf.pop_front(); }
        buf.push_back(line);
    }
}

struct StringVisitor(String);
impl tracing::field::Visit for StringVisitor {
    fn record_str(&mut self, field: &tracing::field::Field, value: &str) {
        if field.name() == "message" { self.0.push_str(value); }
        else { self.0.push_str(&format!(" {}={}", field.name(), value)); }
    }
    fn record_debug(&mut self, field: &tracing::field::Field, value: &dyn std::fmt::Debug) {
        if field.name() == "message" { self.0.push_str(&format!("{:?}", value)); }
        else { self.0.push_str(&format!(" {}={:?}", field.name(), value)); }
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String { format!("Hello, {name}!") }

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
    let filter = EnvFilter::try_from_default_env().unwrap_or_else(|_| {
        EnvFilter::new("info,iroh=debug,iroh_blobs=debug,iroh_relay=debug,rust_lib_my_app=debug")
    });
    let _ = tracing_subscriber::registry()
        .with(filter)
        .with(fmt::layer().with_writer(std::io::stderr).without_time())
        .with(RingBufferLayer)
        .try_init();
    tracing::info!("Sendme: tracing initialized");
}

/// Drain and return all buffered log lines for display in Dart.
pub fn get_debug_logs() -> Vec<String> {
    LOG_BUFFER.write().drain(..).collect()
}
