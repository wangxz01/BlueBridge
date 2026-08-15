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
                print("BlueBridge self-test: \(outputs.count) real CoreAudio output(s)")
                outputs.forEach { print("- \($0.name)\($0.isDefault ? " (default)" : "")") }
                Darwin.exit(outputs.isEmpty ? 2 : 0)
            } catch {
                fputs("BlueBridge self-test failed: \(error.localizedDescription)\n", stderr)
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
            Button(model.isRunning ? "Stop current route" : "Start system audio route") {
                model.isRunning ? model.stop() : model.toggleRoute()
            }
            Divider()
            Button("Open BlueBridge") { NSApp.activate(ignoringOtherApps: true) }
            Button("Quit") { NSApp.terminate(nil) }
        }
    }
}
