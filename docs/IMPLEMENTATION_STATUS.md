# Implementation status

This document is the source of truth for what the repository currently does.

| Capability | Status |
|---|---|
| Windows, macOS, Android application projects | Application shells implemented |
| Shared device, trust, route and preset model | Implemented and tested |
| Route validation and audio-loop rejection | Implemented in shared core |
| Link preference and reconnect backoff | Implemented in shared core |
| Product UI and bilingual copy reference | Available in each shell; fuller reference in `web-prototype/` |
| LAN discovery | Adapter contract only |
| Encrypted realtime audio transport | Not yet implemented |
| Windows WASAPI capture and mixing | Not yet implemented |
| Windows standard A2DP Receiver | Not yet implemented |
| macOS system/application capture | Not yet implemented |
| Android playback capture and final mixing | Not yet implemented |
| BlueBridge Bluetooth media transport | Not yet implemented |

The website is not part of the runtime product and cannot satisfy any system-audio acceptance criterion.
