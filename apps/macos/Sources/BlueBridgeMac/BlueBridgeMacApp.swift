import SwiftUI
import AppKit
import Darwin

@main
struct BlueBridgeMacApp: App {
    @StateObject private var model = AppModel()

    init() {
        if CommandLine.arguments.contains("--self-test") {
            do {
                let outputs = try AudioDeviceService().outputDevices()
                print("BlueBridge 自检：发现 \(outputs.count) 个真实 CoreAudio 输出")
                outputs.forEach { print("- \($0.name)\($0.isDefault ? "（默认）" : "")") }
                Darwin.exit(outputs.isEmpty ? 2 : 0)
            } catch {
                fputs("BlueBridge 自检失败：\(error.localizedDescription)\n", stderr)
                Darwin.exit(1)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 960, minHeight: 650)
        }
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra("BlueBridge", systemImage: "wave.3.right.circle.fill") {
            Button(model.isRunning ? "停止当前路由" : "启动系统音频路由") {
                model.isRunning ? model.stop() : model.toggleRoute()
            }
            Divider()
            Button("打开 BlueBridge") { NSApp.activate(ignoringOtherApps: true) }
            Button("退出") { NSApp.terminate(nil) }
        }
    }
}
