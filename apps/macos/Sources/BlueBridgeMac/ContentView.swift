import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selection = "Overview"

    private let navigation = ["Overview", "Devices", "Presets", "Settings"]

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 22) {
                Label("BlueBridge", systemImage: "wave.3.right.circle.fill")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)

                ForEach(navigation, id: \.self) { item in
                    Button {
                        selection = item
                    } label: {
                        HStack {
                            Image(systemName: icon(for: item))
                            Text(item)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 42)
                        .background(selection == item ? Color.lime : .clear, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(selection == item ? Color.deepTeal : .white.opacity(0.72))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
                Label("Local-first · encrypted", systemImage: "lock.shield")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.58))
                    .padding(12)
            }
            .padding(18)
            .background(Color.deepTeal)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    if selection == "Overview" { overview }
                    else if selection == "Devices" { devices }
                    else if selection == "Presets" { presets }
                    else { settings }
                }
                .padding(30)
            }
            .background(Color(red: 0.94, green: 0.95, blue: 0.92))
        }
        .navigationSplitViewStyle(.balanced)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(selection).font(.system(size: 30, weight: .bold, design: .rounded))
                Text(model.statusMessage).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Label("\(model.devices.filter(\.isOnline).count) devices online", systemImage: "circle.fill")
                .font(.caption)
                .foregroundStyle(Color.deepTeal)
                .padding(.horizontal, 13).padding(.vertical, 9)
                .background(.white.opacity(0.75), in: Capsule())
        }
    }

    private var overview: some View {
        VStack(spacing: 20) {
            routeCard
            mixer
            devices
            presets
        }
    }

    private var routeCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(model.session.isRunning ? "LIVE ROUTE" : "PAUSED").font(.caption2.bold()).foregroundStyle(Color.lime)
                    Text(model.session.name).font(.title2.bold())
                }
                Spacer()
                Button(model.session.isRunning ? "Stop" : "Resume") {
                    model.session.isRunning ? model.stop() : model.startPreset(.library)
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }
            HStack {
                routeNode("laptopcomputer", model.session.source, "Source")
                routeLine
                routeNode("iphone", model.session.sink, "Mix hub")
                routeLine
                routeNode("headphones", model.session.output, "Output")
            }
            Label("\(model.session.link.rawValue) · 18 ms · 48 kHz", systemImage: "bolt.fill")
                .font(.caption.monospaced()).foregroundStyle(.white.opacity(0.68))
        }
        .padding(24)
        .foregroundStyle(.white)
        .background(Color.deepTeal.gradient, in: RoundedRectangle(cornerRadius: 24))
    }

    private func routeNode(_ icon: String, _ title: String, _ detail: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon).font(.title2).frame(width: 56, height: 56).background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 17))
            Text(title).font(.caption.bold()).lineLimit(1)
            Text(detail).font(.caption2).foregroundStyle(.white.opacity(0.55))
        }.frame(maxWidth: .infinity)
    }

    private var routeLine: some View {
        Capsule().fill(Color.lime).frame(width: 45, height: 2)
    }

    private var mixer: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live mixer").font(.headline)
            HStack(spacing: 12) {
                ForEach($model.sources) { $source in
                    VStack(alignment: .leading, spacing: 9) {
                        HStack { Text(source.name).font(.caption.bold()); Spacer(); Button { source.isMuted.toggle() } label: { Image(systemName: source.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill") }.buttonStyle(.plain) }
                        Slider(value: $source.volume, in: 0...1).tint(Color.deepTeal)
                        Text(source.detail).font(.caption2).foregroundStyle(.secondary)
                    }
                    .padding(16).background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 18))
                }
            }
        }
    }

    private var devices: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text("Trusted devices").font(.headline); Spacer(); Button("Scan") { model.scan() } }
            HStack(spacing: 12) {
                ForEach(model.devices) { device in
                    VStack(alignment: .leading, spacing: 9) {
                        HStack { Image(systemName: device.platform == .android ? "iphone" : "desktopcomputer"); Spacer(); Circle().fill(device.isOnline ? .green : .gray).frame(width: 7, height: 7) }
                        Text(device.name).font(.caption.bold())
                        Text("\(device.platform.rawValue) · \(device.latencyMs ?? 0) ms").font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16).background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 18))
                }
            }
        }
    }

    private var presets: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Presets").font(.headline)
            HStack(spacing: 12) {
                preset("Gaming + Study", "Phone → Windows → 2.4G", .gamingStudy)
                preset("Library", "Mac → Android → headphones", .library)
            }
        }
    }

    private func preset(_ title: String, _ route: String, _ preset: BuiltInPreset) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) { Text(title).font(.caption.bold()); Text(route).font(.caption2).foregroundStyle(.secondary) }
            Spacer(); Button { model.startPreset(preset) } label: { Image(systemName: "play.fill") }
        }
        .padding(16).frame(maxWidth: .infinity).background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 18))
    }

    private var settings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connection & recovery").font(.headline)
            Toggle("Reconnect trusted devices automatically", isOn: .constant(true))
            Toggle("Prefer the best local link", isOn: .constant(true))
            Toggle("Prevent BlueBridge audio feedback", isOn: .constant(true))
        }
        .padding(22).background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 20))
    }

    private func icon(for item: String) -> String {
        ["Overview": "rectangle.grid.2x2", "Devices": "display.2", "Presets": "sparkles", "Settings": "gearshape"][item] ?? "circle"
    }
}

extension Color {
    static let deepTeal = Color(red: 0.07, green: 0.20, blue: 0.22)
    static let lime = Color(red: 0.85, green: 1.0, blue: 0.46)
}
