# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker image for cross-compiling Rust, Go, and C/C++ code targeting Android (via NDK), GNU/Linux, and Windows (via MinGW + Wine). Published to Docker Hub as `ykasidit/android_ndk_c_rust_go_builder_ext`.

Base image: `ghcr.io/cirruslabs/android-sdk` (cirruslabs). The `IMAGE` file contains the full Docker Hub tag including version info.

## Build and Push

```bash
# Build the Docker image (reads tag from IMAGE file)
sudo docker build . -t $(cat IMAGE)

# Push to Docker Hub
sudo docker push $(cat IMAGE)
```

There are no tests or linting beyond the Dockerfile's own `RUN` verification steps (e.g., `ndk-build --version`, `rustc --version`, `cargo build --offline` of hello_world).

## Key Version Pins (in Dockerfile)

- **Android SDK**: ARG `android_sdk_ver` (currently `34-ndk`), NDK `26.2.11394342`
- **Rust**: ENV `RUST_VER` (currently `1.86.0`), with Android targets `aarch64-linux-android`, `armv7-linux-androideabi`, plus Windows/Linux cross targets
- **Go**: `go1.22.2.linux-amd64`
- **Flutter**: ARG `flutter_ver` (currently `3.24.3`)
- **Java**: OpenJDK 17

## Branching Convention

The `IMAGE` file tag typically matches the branch name (e.g., branch `34-ndk` produces tag `34-ndk-rs1.86.0`). Update `IMAGE` when changing version pins.

## Architecture Notes

- Runs as `builder` user (UID 1000) by default; root is used only during package installation
- Rust toolchain installed under `/home/builder/.cargo` via rustup
- Android NDK/SDK at `/opt/android-sdk-linux`; key env vars: `ANDROID_NDK_HOME`, `ANDROID_HOME`, `ANDROID_TOOLCHAIN`
- `hello_world/` is a minimal Rust project used as a smoke test during image build (offline cargo build)
- Wine is installed for testing Windows cross-compiled binaries
- MinGW cross-compilers available for `x86_64-pc-windows-gnu` and `i686-pc-windows-gnu` targets
