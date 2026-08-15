# BlueBridge architecture

BlueBridge is three native applications connected by a shared local protocol and domain model.

```text
Windows app ─┐
macOS app  ──┼── discovery / trust / encrypted audio transport ── route sink + mixer
Android app ─┘
```

## Layers

1. **Native UI** — WPF on Windows, SwiftUI on macOS, and Jetpack Compose on Android.
2. **Platform audio adapter** — WASAPI and Windows Bluetooth APIs; CoreAudio/ScreenCaptureKit; AudioPlaybackCapture/MediaProjection and Android AudioTrack.
3. **Shared route core** — device identity, trust, route validation, presets, link selection, loop prevention, and recovery state.
4. **Transport** — encrypted LAN audio sessions with local discovery; BlueBridge Bluetooth fallback; Windows standard A2DP Receiver as a separate input adapter.

The shared Rust crate is intentionally platform-neutral. Each application owns permission prompts, OS lifecycle, tray/menu behavior, and device-specific audio routing.

## Proposed media pipeline

1. Capture PCM frames from a system or application source.
2. Stamp frames with a session ID and monotonic presentation time.
3. Resample into the negotiated session format.
4. Encode for the selected quality preference.
5. Encrypt and transport frames over the selected local link.
6. Jitter-buffer, decode, resample, and mix on the sink.
7. Mark BlueBridge render endpoints so capture adapters can reject feedback loops.

## Security boundary

- Device identity is created locally.
- First pairing requires confirmation on both devices.
- Trusted-device credentials are stored in the OS credential store.
- Audio sessions use ephemeral keys and never require a cloud account.
- Discovery advertisements contain no audio and do not grant session access.
