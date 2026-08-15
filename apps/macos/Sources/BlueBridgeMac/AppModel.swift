import CoreAudio
import Foundation
import AppKit

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var outputs: [AudioOutputDevice] = []
    @Published var selectedOutputID: AudioDeviceID?
    @Published private(set) var routerState: RouterState = .idle
    @Published private(set) var lastError: String?

    let localDeviceName = Host.current().localizedName ?? "This Mac"

    private let deviceService = AudioDeviceService()
    private let router = SystemAudioRouter()

    init() {
        router.onStateChange = { [weak self] state in
            self?.routerState = state
            if case .failed(let message) = state { self?.lastError = message }
        }
        refreshOutputs()
    }

    var selectedOutput: AudioOutputDevice? {
        outputs.first { $0.id == selectedOutputID }
    }

    var isRunning: Bool { routerState == .running }
    var isBusy: Bool { routerState == .starting || routerState == .stopping }
    var canStart: Bool { selectedOutputID != nil && !isBusy }

    func refreshOutputs() {
        do {
            outputs = try deviceService.outputDevices()
            if selectedOutputID == nil || !outputs.contains(where: { $0.id == selectedOutputID }) {
                selectedOutputID = outputs.first(where: \.isDefault)?.id ?? outputs.first?.id
            }
            lastError = nil
        } catch {
            outputs = []
            selectedOutputID = nil
            lastError = error.localizedDescription
        }
    }

    func toggleRoute() {
        Task {
            if isRunning {
                await router.stop()
                return
            }
            guard let selectedOutputID else { return }
            lastError = nil
            do {
                try await router.start(outputDeviceID: selectedOutputID)
            } catch {
                lastError = error.localizedDescription
                routerState = .failed(error.localizedDescription)
            }
        }
    }

    func stop() {
        Task { await router.stop() }
    }

    func openPrivacySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
        NSWorkspace.shared.open(url)
    }
}
