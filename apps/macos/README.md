# BlueBridge for macOS

SwiftUI application for macOS 14 and newer. Version 0.1 enumerates real CoreAudio output devices and routes real macOS system audio to the selected output using ScreenCaptureKit and AVAudioEngine. It does not display simulated remote devices or connections.

## Build an application bundle

```bash
bash apps/macos/scripts/package.sh
```

This creates an ad-hoc signed `artifacts/BlueBridge.app` and a v0.2.0 zip archive for local testing. The first route start requests Screen & System Audio Recording permission. Reopen the application after granting it.

Native integration targets:

- multi-source remote mixing
- per-application ScreenCaptureKit filtering
- local discovery and encrypted media transport
- BlueBridge Bluetooth fallback adapter
- Keychain-backed trusted-device identity
