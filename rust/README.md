# NullSound — Rust rewrite

This directory contains the native Rust/Slint rewrite of NullSound on the `rust-rewrite` branch.

The existing Flutter application on `main` is untouched.

## Stack

- Rust 2024
- Slint 1.18 for the Android UI
- Rust-owned application state
- Reqwest + rustls for networking
- Serde/JSON for API data

Slint officially supports Android applications written in Rust through its Android Activity backend.

## Current app

The first Rust build includes:

- Native Android entry point
- Home screen
- Search screen and query state
- Library screen
- Bottom navigation
- Mini-player state
- Rust-side event handling
- Android API 26+ target

## Roadmap

The next implementation passes will move the real NullSound functionality into Rust:

1. YouTube Music search
2. YouTube Music playlist/library parsing
3. Signed-in session and stream resolution
4. Native audio playback
5. Android background playback/media controls
6. Queue and swipe player
7. Lyrics
8. Downloads
9. Sleep timer
10. Artwork and dynamic player colors

## Build

Install the Android target:

```bash
rustup target add aarch64-linux-android
```

Then configure the Android SDK/NDK and run:

```cargo install cargo-apk
cd rust
cargo apk run --target aarch64-linux-android --lib
```

The Rust Android build requires the Android SDK/NDK. Slint's Android documentation recommends API 26+ and documents the cargo-apk workflow.
