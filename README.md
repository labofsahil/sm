# my_app

A new Flutter project.

## Rust bridge bindings

The Dart package, Rust crate, and generated bindings must all use the same
`flutter_rust_bridge` version. After changing the bridge version or Rust APIs,
regenerate the bindings with the matching generator. Set `FRB_VERSION` to the
version declared in `pubspec.yaml` and `rust/Cargo.toml`:

```sh
cargo install flutter_rust_bridge_codegen --version "$FRB_VERSION" --locked
flutter pub get
flutter_rust_bridge_codegen generate
```

Commit the generated files in `lib/src/rust/` and `rust/src/frb_generated.rs`.
A generator/runtime version mismatch stops startup at `RustLib.init()` before
the dashboard is displayed. After updating the bindings, rebuild the app with
`flutter run`; hot reload does not rebuild the native Rust library.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
