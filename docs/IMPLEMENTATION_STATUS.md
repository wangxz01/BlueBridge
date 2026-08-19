# 实现状态

本文档是仓库当前能力边界的事实来源。未完成的能力不会以模拟状态冒充真实实现。

| 能力 | 状态 |
|---|---|
| Flutter Windows、macOS、Android 统一应用工程 | 已创建并完成 UI 重置 |
| Flutter 中文响应式 UI 与真实空状态 | 已实现并通过组件测试 |
| Flutter 平台音频网关 | 尚未接入 |
| 旧 Windows、macOS、Android 原生工程 | 作为迁移参考保留 |
| 共享设备、信任、路由和预设模型 | 已实现并通过测试 |
| 路由校验与音频环路阻止 | 已在共享核心实现 |
| 链路偏好与重连退避 | 已在共享核心实现 |
| macOS 系统音频采集 | v0.2 已通过 ScreenCaptureKit 实现 |
| macOS CoreAudio 输出发现与本机播放 | v0.2 已实现 |
| macOS 逐应用采集 | 未实现 |
| 局域网发现 | 仅有适配器契约，未实现 |
| 加密实时音频传输 | 未实现 |
| Windows WASAPI 采集与混音 | 未实现 |
| Windows 标准 A2DP Receiver | 未实现 |
| Android 播放捕获与最终混音 | 未实现 |
| BlueBridge Bluetooth 媒体传输 | 未实现 |
| 三端签名、安装器与自动更新 | 未实现 |

`web-prototype/` 只是 UI 参考，不属于运行时产品，也不能满足任何系统音频验收条件。
