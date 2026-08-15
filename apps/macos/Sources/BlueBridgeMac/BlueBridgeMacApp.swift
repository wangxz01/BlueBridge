import SwiftUI
import AppKit

@main
struct BlueBridgeMacApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 960, minHeight: 650)
        }
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra("BlueBridge", systemImage: "wave.3.right.circle.fill") {
            Button(model.session.isRunning ? "Stop current route" : "Start Library") {
                model.session.isRunning ? model.stop() : model.startPreset(.library)
            }
            Divider()
            Button("Open BlueBridge") { NSApp.activate(ignoringOtherApps: true) }
            Button("Quit") { NSApp.terminate(nil) }
        }
    }
}
