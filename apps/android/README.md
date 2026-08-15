# BlueBridge for Android

Kotlin/Jetpack Compose application shell targeting Android 10 and newer. It includes the Android hub flow, local/remote mixer channels, trusted devices, presets, permissions, and an explicit platform-audio adapter contract.

Native integration targets:

- user-approved MediaProjection and AudioPlaybackCapture
- clear handling of applications that disallow playback capture
- AudioTrack sink and mixing while following the current system output route
- foreground media service and automatic recovery
- local discovery, encrypted media transport, and BlueBridge Bluetooth fallback

Build with Android Studio using JDK 17 and Android SDK 35.
