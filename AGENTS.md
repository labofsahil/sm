# Repository Guidelines

## Project Structure & Module Organization

This repository is an Android Sendme client built with Flutter, with a Rust
backend based on upstream `n0-computer/sendme`. It uses
`fzyzcjy/flutter_rust_bridge` to connect the Dart UI to Rust transfer APIs.
`lib/main.dart` initializes the bridge and launches the app. UI code lives in
`lib/src/views/`, `widgets/`, and `theme/`; models and storage helpers live in
`models/` and `services/`. Rust transfer APIs and logging utilities live in
`rust/src/api/`. `lib/src/rust/` and `rust/src/frb_generated.rs` contain generated
bindings. `rust_builder/` integrates native builds through Cargokit.
Platform folders contain runner configuration and platform assets; no custom
Flutter asset bundle is currently declared. `integration_test/` contains the
dashboard startup test; `test_driver/` contains its driver.

## Build, Test, and Development Commands

- `flutter pub get`: resolve Dart dependencies.
- `flutter run`: build and launch on a selected device.
- `flutter analyze`: run configured Flutter lints.
- `dart format lib integration_test test_driver`: format Dart sources.
- `cargo fmt --manifest-path rust/Cargo.toml`: format Rust sources.
- `cargo check --locked --manifest-path rust/Cargo.toml`: check Rust compilation.
- `cargo test --locked --manifest-path rust/Cargo.toml`: run backend tests.
- `flutter test integration_test/simple_test.dart -d linux`: verify native
  initialization and dashboard rendering; requires Linux build tools.
- `flutter build apk --debug`: build the Android APK, matching CI.

## Coding Style & Naming Conventions

Use formatter-controlled indentation: two spaces for Dart, four for Rust.
Follow `flutter_lints` and prefer single-quoted Dart strings. Use `snake_case`
filenames, `UpperCamelCase` types, Dart `lowerCamelCase` members, and Rust
`snake_case` functions. Edit source APIs rather than generated bindings.

## Testing Guidelines

Flutter tests use `flutter_test` and `integration_test`; Rust uses `#[test]`
and `#[tokio::test]`. Name Dart tests `*_test.dart` and Rust tests `test_*`.
Cover changed transfer behavior, cancellation, invalid tickets, and path
validation. No numeric coverage threshold is configured. Run startup integration
tests after bridge changes; CI currently builds Android without running tests.

## Commit & Pull Request Guidelines

History mixes short messages with dependency commits such as
`build(deps): bump flutter_rust_bridge`; no uniform convention is enforced.
Prefer descriptive messages such as `fix: align bridge bindings with runtime`.
PRs should explain behavior changes, link relevant issues, report validation,
and include screenshots for UI changes.

## Rust Bridge Updates

Keep Dart, Rust, and generator versions aligned. Follow README regeneration
instructions and commit generated bindings together with dependency changes.
Rebuild native code after updates; hot reload is insufficient.
