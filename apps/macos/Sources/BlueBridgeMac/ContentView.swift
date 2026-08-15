import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    routeCard
                    setupCard
                    outputDevices
                    nextCapabilities
                }
                .padding(30)
            }
            .background(Color.canvas)
        }
        .navigationSplitViewStyle(.balanced)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 22) {
            Label("BlueBridge", systemImage: "wave.3.right.circle.fill")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 10)

            Label("Audio route", systemImage: "point.3.connected.trianglepath.dotted")
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
                .background(Color.lime, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(Color.deepTeal)

            Spacer()
            VStack(alignment: .leading, spacing: 6) {
                Label("Local only", systemImage: "lock.shield")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                Text("This build captures and plays audio entirely on this Mac.")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
        }
        .padding(18)
        .background(Color.deepTeal)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("System audio route")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Text(model.localDeviceName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Label(model.routerState.label, systemImage: model.isRunning ? "waveform.circle.fill" : "circle")
                .font(.caption)
                .foregroundStyle(model.isRunning ? .green : Color.deepTeal)
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                .background(.white.opacity(0.78), in: Capsule())
        }
    }

    private var routeCard: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.isRunning ? "LIVE AUDIO" : "LOCAL ROUTE")
                        .font(.caption2.bold())
                        .foregroundStyle(Color.lime)
                    Text("Mac system audio")
                        .font(.title2.bold())
                }
                Spacer()
                Button(model.isRunning ? "Stop" : "Start") { model.toggleRoute() }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.lime)
                    .foregroundStyle(Color.deepTeal)
                    .disabled(!model.canStart)
            }

            HStack(spacing: 16) {
                routeNode(icon: "laptopcomputer", title: model.localDeviceName, detail: "System audio")
                Capsule().fill(Color.lime).frame(height: 2)
                routeNode(icon: "headphones", title: model.selectedOutput?.name ?? "No output", detail: "CoreAudio output")
            }

            Label("48 kHz · stereo · current process excluded", systemImage: "waveform")
                .font(.caption.monospaced())
                .foregroundStyle(.white.opacity(0.66))
        }
        .padding(25)
        .foregroundStyle(.white)
        .background(Color.deepTeal.gradient, in: RoundedRectangle(cornerRadius: 24))
    }

    private func routeNode(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 54, height: 54)
                .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.caption.bold()).lineLimit(1)
                Text(detail).font(.caption2).foregroundStyle(.white.opacity(0.55))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Route setup").font(.headline)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Source").font(.caption2.bold()).foregroundStyle(.secondary)
                    Label("macOS system audio", systemImage: "waveform")
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Output").font(.caption2.bold()).foregroundStyle(.secondary)
                    Picker("Output", selection: $model.selectedOutputID) {
                        ForEach(model.outputs) { device in
                            Text(device.isDefault ? "\(device.name) — Default" : device.name)
                                .tag(Optional(device.id))
                        }
                    }
                    .labelsHidden()
                    .frame(width: 260)
                    .disabled(model.isRunning)
                }
                Button { model.refreshOutputs() } label: { Image(systemName: "arrow.clockwise") }
                    .help("Refresh real CoreAudio outputs")
                    .disabled(model.isRunning)
            }

            if let error = model.lastError {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(error).font(.caption)
                        if model.routerState == .requestingPermission || error.contains("Screen") {
                            Button("Open Privacy Settings") { model.openPrivacySettings() }
                                .font(.caption)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(21)
        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
    }

    private var outputDevices: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Real audio outputs").font(.headline)
                    Text("Read directly from CoreAudio on this Mac").font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(model.outputs.count) found").font(.caption).foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: 12)], spacing: 12) {
                ForEach(model.outputs) { device in
                    HStack(spacing: 12) {
                        Image(systemName: device.isDefault ? "speaker.wave.3.fill" : "speaker.wave.2")
                            .foregroundStyle(Color.deepTeal)
                            .frame(width: 42, height: 42)
                            .background(Color.teal.opacity(0.09), in: RoundedRectangle(cornerRadius: 13))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(device.name).font(.caption.bold()).lineLimit(1)
                            Text(device.isDefault ? "System default" : "Available")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if device.id == model.selectedOutputID {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        }
                    }
                    .padding(14)
                    .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 17))
                }
            }
        }
    }

    private var nextCapabilities: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Not in this build").font(.headline)
            Text("LAN device discovery, remote audio transport, app-by-app capture and BlueBridge Bluetooth are disabled until their native engines are implemented. No placeholder devices or fake connection state are shown.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(21)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 20))
    }
}

extension Color {
    static let deepTeal = Color(red: 0.07, green: 0.20, blue: 0.22)
    static let lime = Color(red: 0.85, green: 1.0, blue: 0.46)
    static let canvas = Color(red: 0.94, green: 0.95, blue: 0.92)
}
