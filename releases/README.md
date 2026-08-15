# Builds

## BlueBridge for macOS v0.1.0

- Target: Apple silicon, macOS 14 or newer
- SHA-256: `b97b650326a2029ae829e9b82d6d19fe17239037faa0e27408914a672eab7786`
- Signature: ad-hoc local testing signature
- Implemented: real CoreAudio output discovery; real ScreenCaptureKit system-audio capture; AVAudioEngine output routing; menu bar control
- Not implemented: remote device discovery, LAN transport, BlueBridge Bluetooth, per-application capture, multi-device mixing

After the first Start, grant Screen & System Audio Recording permission and reopen BlueBridge. A Developer ID signature and notarization are required before general distribution.
