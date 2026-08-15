import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 26) {
                Text("BlueBridge")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text("音频路由")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(.white, in: RoundedRectangle(cornerRadius: 8))
                    Text("设备")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.58))
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                    Text("设置")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.58))
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                }

                Spacer()
                VStack(alignment: .leading, spacing: 5) {
                    Text("仅在本机处理").font(.caption.weight(.semibold))
                    Text("当前版本不会上传音频，也不显示模拟设备。")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(.white)
            }
            .padding(22)
            .background(Color.ink)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    pageHeader
                    currentRoute
                    routeSettings
                    deviceList
                    unavailableFeatures
                }
                .padding(32)
            }
            .background(Color.canvas)
        }
        .navigationSplitViewStyle(.balanced)
    }

    private var pageHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("系统音频路由")
                    .font(.system(size: 29, weight: .bold))
                Text(model.localDeviceName)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
            Spacer()
            statusBadge
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(model.isRunning ? Color.statusGreen : Color.secondaryText)
                .frame(width: 7, height: 7)
            Text(model.routerState.label)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white, in: Capsule())
        .overlay(Capsule().stroke(Color.divider, lineWidth: 1))
    }

    private var currentRoute: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前路由")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                    Text("Mac 系统音频")
                        .font(.title3.weight(.semibold))
                }
                Spacer()
                Button(model.isRunning ? "停止" : "启动") { model.toggleRoute() }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.ink)
                    .disabled(!model.canStart)
            }

            HStack(spacing: 14) {
                infoNode(index: "01", label: "来源", value: "系统音频")
                Image(systemName: "arrow.right").foregroundStyle(Color.secondaryText)
                infoNode(index: "02", label: "设备", value: model.localDeviceName)
                Image(systemName: "arrow.right").foregroundStyle(Color.secondaryText)
                infoNode(index: "03", label: "输出", value: model.selectedOutput?.name ?? "未选择")
            }

            Divider()
            HStack(spacing: 24) {
                detailItem("格式", "48 kHz · 立体声")
                detailItem("捕获", "系统音频")
                detailItem("本应用声音", "已排除")
            }
        }
        .padding(22)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.divider, lineWidth: 1))
    }

    private func infoNode(index: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Text(index).font(.caption2.monospaced())
                Text(label).font(.caption2)
            }
            .foregroundStyle(Color.secondaryText)
            Text(value)
                .font(.callout.weight(.semibold))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.canvas, in: RoundedRectangle(cornerRadius: 9))
    }

    private func detailItem(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.caption2).foregroundStyle(Color.secondaryText)
            Text(value).font(.caption.weight(.medium))
        }
    }

    private var routeSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("路由设置", "选择本次路由使用的真实输出设备")
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("音频来源").font(.caption).foregroundStyle(Color.secondaryText)
                    Text("macOS 系统音频").font(.callout.weight(.medium))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    Text("输出设备").font(.caption).foregroundStyle(Color.secondaryText)
                    Picker("输出设备", selection: $model.selectedOutputID) {
                        ForEach(model.outputs) { device in
                            Text(device.isDefault ? "\(device.name)（默认）" : device.name)
                                .tag(Optional(device.id))
                        }
                    }
                    .labelsHidden()
                    .frame(width: 280)
                    .disabled(model.isRunning)
                }
                Button("刷新") { model.refreshOutputs() }
                    .buttonStyle(.bordered)
                    .disabled(model.isRunning)
            }

            if let error = model.lastError {
                HStack(alignment: .top, spacing: 9) {
                    Image(systemName: "exclamationmark.circle").foregroundStyle(Color.warning)
                    VStack(alignment: .leading, spacing: 7) {
                        Text(error).font(.caption)
                        if model.routerState == .requestingPermission || error.contains("屏幕") {
                            Button("打开隐私设置") { model.openPrivacySettings() }.font(.caption)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.warning.opacity(0.08), in: RoundedRectangle(cornerRadius: 9))
            }
        }
        .padding(22)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.divider, lineWidth: 1))
    }

    private var deviceList: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("输出设备", "由 CoreAudio 实时读取，共 \(model.outputs.count) 个")
            ForEach(model.outputs) { device in
                HStack(spacing: 12) {
                    Image(systemName: "speaker.wave.2")
                        .frame(width: 34, height: 34)
                        .background(Color.canvas, in: RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(device.name).font(.callout.weight(.medium))
                        Text(device.isDefault ? "系统默认输出" : "可用输出")
                            .font(.caption2).foregroundStyle(Color.secondaryText)
                    }
                    Spacer()
                    if device.id == model.selectedOutputID {
                        Text("已选择").font(.caption).foregroundStyle(Color.statusGreen)
                    }
                }
                if device.id != model.outputs.last?.id { Divider() }
            }
        }
        .padding(22)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.divider, lineWidth: 1))
    }

    private var unavailableFeatures: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("暂不可用", "以下能力会在后续版本接入真实实现")
            capabilityRow("附近设备发现", detail: "局域网与蓝牙扫描")
            Divider()
            capabilityRow("远端音频传输", detail: "Mac 与 Windows、Android 之间传输")
            Divider()
            capabilityRow("多路混音", detail: "本机与远端来源独立音量")
        }
        .padding(22)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.divider, lineWidth: 1))
    }

    private func capabilityRow(_ title: String, detail: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.callout.weight(.medium))
                Text(detail).font(.caption2).foregroundStyle(Color.secondaryText)
            }
            Spacer()
            Text("暂不可用").font(.caption).foregroundStyle(Color.secondaryText)
        }
    }

    private func sectionTitle(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.headline)
            Text(detail).font(.caption2).foregroundStyle(Color.secondaryText)
        }
    }
}

extension Color {
    static let ink = Color(red: 0.09, green: 0.09, blue: 0.09)
    static let canvas = Color(red: 0.96, green: 0.96, blue: 0.95)
    static let divider = Color(red: 0.86, green: 0.86, blue: 0.84)
    static let secondaryText = Color(red: 0.42, green: 0.42, blue: 0.40)
    static let statusGreen = Color(red: 0.18, green: 0.49, blue: 0.31)
    static let warning = Color(red: 0.64, green: 0.39, blue: 0.07)
}
