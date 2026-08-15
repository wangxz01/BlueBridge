import Foundation

enum Platform: String, CaseIterable, Identifiable {
    case windows = "Windows"
    case macOS = "macOS"
    case android = "Android"
    var id: String { rawValue }
}

enum LinkKind: String {
    case local = "Local"
    case lan = "LAN"
    case hotspot = "Phone hotspot"
    case standardBluetooth = "Standard Bluetooth"
    case blueBridgeBluetooth = "BlueBridge Bluetooth"
}

struct BridgeDevice: Identifiable, Hashable {
    let id: UUID
    var name: String
    var platform: Platform
    var isOnline: Bool
    var isTrusted: Bool
    var latencyMs: Int?
}

struct MixerSource: Identifiable {
    let id: UUID
    var name: String
    var detail: String
    var volume: Double
    var isMuted: Bool
}

struct RouteSession {
    var name: String
    var source: String
    var sink: String
    var output: String
    var link: LinkKind
    var isRunning: Bool
}

enum BuiltInPreset {
    case gamingStudy
    case library
}

@MainActor
final class AppModel: ObservableObject {
    @Published var devices: [BridgeDevice] = [
        .init(id: UUID(), name: "This Mac", platform: .macOS, isOnline: true, isTrusted: true, latencyMs: 0),
        .init(id: UUID(), name: "Pixel 9", platform: .android, isOnline: true, isTrusted: true, latencyMs: 18),
        .init(id: UUID(), name: "Gaming PC", platform: .windows, isOnline: true, isTrusted: true, latencyMs: 24),
    ]

    @Published var sources: [MixerSource] = [
        .init(id: UUID(), name: "Mac system audio", detail: "Local", volume: 0.82, isMuted: false),
        .init(id: UUID(), name: "Pixel 9 · Media", detail: "LAN", volume: 0.64, isMuted: false),
    ]

    @Published var session = RouteSession(
        name: "Library",
        source: "This Mac",
        sink: "Pixel 9",
        output: "Pixel Buds Pro",
        link: .hotspot,
        isRunning: true
    )

    @Published var statusMessage = "Local audio only — nothing is uploaded"

    func startPreset(_ preset: BuiltInPreset) {
        switch preset {
        case .gamingStudy:
            session = .init(name: "Gaming + Study", source: "Pixel 9", sink: "Gaming PC", output: "2.4G headset", link: .standardBluetooth, isRunning: true)
        case .library:
            session = .init(name: "Library", source: "This Mac", sink: "Pixel 9", output: "Pixel Buds Pro", link: .hotspot, isRunning: true)
        }
        statusMessage = "Route started · best local link selected"
    }

    func stop() {
        session.isRunning = false
        statusMessage = "Route stopped · configuration preserved"
    }

    func scan() {
        statusMessage = "Scanning the local network and Bluetooth…"
    }
}
