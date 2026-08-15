# BlueBridge for Windows

WPF/.NET 8 application shell targeting Windows 10 2004 and newer. It includes route creation, live mixer controls, trusted devices, presets, and explicit adapter contracts for system audio and standard Bluetooth reception.

Native integration targets:

- WASAPI loopback and per-process audio capture
- low-latency local render and multi-source mix graph
- Windows standard A2DP Sink receiver
- local discovery and encrypted media transport
- system tray and automatic recovery lifecycle

The current `DevelopmentAudioService` and `DevelopmentBluetoothReceiver` are deliberately named development adapters; they do not claim native audio behavior.
