<p align="center">
  <img src="branding/bluebridge-logo.png" width="260" alt="BlueBridge Logo">
</p>

<h1 align="center">BlueBridge</h1>

<p align="center"><strong>一个耳机，听见所有设备。</strong></p>

<p align="center">
  面向 Windows、macOS 和 Android 的本地优先个人音频路由器。
</p>

> 当前阶段：macOS 已有可运行的真实音频版本；Windows 与 Android 已完成原生应用骨架和统一中文界面，平台音频能力仍在实现。项目是三个原生应用，不是网站。

## BlueBridge 是什么

BlueBridge 希望让用户只佩戴一副耳机，就能接收和管理来自电脑、手机及其他设备的音频。三端使用各自平台的原生技术实现，设备、路由、信任关系、预设和恢复策略由共享核心统一描述。

- 本地优先：设备发现、配对和音频传输优先在局域网或蓝牙内完成。
- 隐私优先：不依赖云端转发，后续传输层默认使用端到端加密。
- 信息优先：三端界面统一使用中文、低色彩和清晰的信息层级。
- 不模拟状态：未接入的系统能力会明确标记，不把演示数据当作真实设备或连接。

## 三端当前状态

| 端 | 当前可用能力 | 接下来要接入 |
|---|---|---|
| **macOS** | SwiftUI 原生应用；真实 CoreAudio 输出设备枚举；ScreenCaptureKit 系统音频采集；AVAudioEngine 本机输出 | 局域网发送、逐应用采集、签名与安装体验 |
| **Windows** | WPF / .NET 8 原生应用；设备、路由、混音、可信设备和预设界面 | WASAPI 采集与混音、标准 A2DP 接收、后台恢复 |
| **Android** | Kotlin / Jetpack Compose 原生应用；设备、路由、混音、可信设备和预设界面 | MediaProjection / AudioPlaybackCapture、AudioTrack 输出、前台服务 |
| **共享核心** | Rust 路由模型；路由校验；音频环路阻止；链路选择；重连退避；单元测试 | 与三端原生适配器集成、统一会话与协议版本 |

网页原型仅保留在 `web-prototype/` 作为历史 UI 参考，不参与产品运行。

## 当前架构

![BlueBridge 当前架构](docs/assets/bluebridge-architecture.png)

三端应用负责系统权限、音频采集、输出和生命周期；共享核心负责统一业务规则；尚待完成的传输层负责发现、可信配对、加密会话、编码、抖动缓冲和多路混音。

目标数据流：

```text
系统或应用音频
  → 原生采集
  → 重采样与编码
  → 加密本地传输
  → 抖动缓冲与解码
  → 多路混音
  → 用户选择的耳机或扬声器
```

更完整的分层说明见 [架构文档](docs/ARCHITECTURE.md)。

## 接下来要实现

![BlueBridge 后续实现路线](docs/assets/bluebridge-roadmap.png)

按可交付价值排序：

1. **传输基础**：局域网发现、可信配对、密钥保存、加密会话。
2. **实时音频**：音频编码、时钟同步、抖动缓冲、丢包与重连策略。
3. **Windows 核心**：WASAPI 回环/逐进程采集、标准 A2DP Sink、多路混音。
4. **Android 核心**：用户授权的播放捕获、AudioTrack 输出、前台服务和后台恢复。
5. **蓝牙与发布**：BlueBridge Bluetooth 备用链路、三端签名、安装包与自动更新。

准确的实现边界见 [实现状态](docs/IMPLEMENTATION_STATUS.md)。

## 下载当前版本

- [BlueBridge for macOS v0.2.0](releases/BlueBridge-macOS-v0.2.0.zip) — Apple 芯片，macOS 14+

此版本不包含模拟设备或模拟连接状态。它会读取真实 CoreAudio 输出设备，并通过 ScreenCaptureKit 与 AVAudioEngine 路由真实的 macOS 系统音频；局域网和蓝牙跨设备路由尚未启用。

## 仓库结构

```text
apps/
  windows/          Windows 桌面应用（WPF / .NET）
  macos/            macOS 应用（SwiftUI）
  android/          Android 应用（Kotlin / Compose）
shared/
  bluebridge-core/  共享路由、设备、信任、预设与恢复模型（Rust）
branding/           项目 Logo 与品牌源文件
docs/               架构、状态与 README 信息图
releases/           可下载版本
web-prototype/      仅供参考的旧网页原型
```

## 本地验证

共享核心：

```bash
cargo test --workspace
```

macOS：

```bash
swift build --package-path apps/macos
./apps/macos/scripts/package.sh
```

Android 需要 JDK 17 与 Android SDK 35；Windows 需要 Windows 10 2004+ 与 .NET 8 SDK。各端的系统音频能力必须在对应操作系统上完成和验证。

## 品牌资源

项目主 Logo 使用 [`branding/bluebridge-logo.png`](branding/bluebridge-logo.png)。仓库已预置：

- macOS：`apps/macos/Resources/BlueBridge.icns`
- Windows：`apps/windows/Resources/BlueBridge.ico`
- Android：`apps/android/app/src/main/res/drawable/bluebridge_logo.png`

三端均从同一张 Logo 源图派生，后续替换源图时应同步生成平台图标。
