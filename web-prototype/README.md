# BlueBridge

BlueBridge is a control-center prototype for a cross-platform personal audio router across Windows, macOS, and Android.

The interface implements the product's core three-step flow—choose a source, choose a target, and start—along with live route status, per-source mixing, trusted devices, presets, local preferences, and Chinese/English UI.

## Run locally

```bash
npm install
npm run dev
```

## Scope

This repository currently contains the interactive control layer. System-audio capture, virtual audio devices, A2DP Sink support, encrypted transport, and native background services require platform-specific Windows, macOS, and Android clients.
