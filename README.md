# BlueBridge

**One headset. Every device.**

BlueBridge is a local-first personal audio router for Windows, macOS, and Android. The product is three native applications backed by one shared routing model—not a website.

## Repository layout

```text
apps/
  windows/        Windows desktop app (WPF/.NET)
  macos/          macOS app (SwiftUI)
  android/        Android app (Kotlin/Compose)
shared/
  bluebridge-core Shared route, device, trust, preset and recovery model (Rust)
docs/             Architecture and implementation status
web-prototype/    UI reference only; not the product runtime
```

## Current milestone

The repository now contains the three native application shells and a tested shared domain core. Each app presents the same product concepts: devices, routes, mixer channels, presets, trusted pairing, and automatic recovery.

Platform audio drivers, encrypted realtime transport, discovery, standard Windows A2DP Sink, and production Bluetooth transports remain native integration work. See [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md) for the exact boundary.

## Validate the shared core

```bash
cargo test --workspace
```

The macOS shell can also be compiled on macOS:

```bash
swift build --package-path apps/macos
```

The previous web control-center prototype remains runnable from `web-prototype/` as a visual reference.
