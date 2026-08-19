# BlueBridge Flutter 应用

这是 Windows、macOS、Android 共用的新前台工程。当前版本完成 UI 重置：统一中文、黑白灰信息设计、桌面与移动响应式布局，并且不包含模拟设备、模拟连接或模拟延迟。

## 运行

```bash
flutter pub get
flutter run -d macos
```

Windows 版本必须在 Windows 上编译，Android 版本需要 JDK 17 和 Android SDK。

如果仓库位于会自动写入 Finder 扩展属性的同步目录，macOS 签名可能报告 `resource fork, Finder information, or similar detritus not allowed`。可以临时将 Flutter `build-dir` 指向 `/private/tmp`，构建完成后再清除该全局设置。

## 当前边界

- 已完成：统一应用壳、导航、空状态、品牌资源、响应式布局和组件测试。
- 待迁移：macOS ScreenCaptureKit / CoreAudio 适配器。
- 待实现：Windows WASAPI / A2DP、Android MediaProjection / AudioTrack。
- 待接入：Rust 共享核心、局域网发现、可信配对和加密实时音频。

旧平台工程暂时保留在相邻目录，直到对应 Flutter 插件达到功能等价后再移除。
