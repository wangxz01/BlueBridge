import AVFoundation
import CoreAudio
import CoreGraphics
import CoreMedia
import Foundation
import ScreenCaptureKit

enum RouterState: Equatable {
    case idle
    case requestingPermission
    case starting
    case running
    case stopping
    case failed(String)

    var label: String {
        switch self {
        case .idle: return "可以启动"
        case .requestingPermission: return "需要系统权限"
        case .starting: return "正在启动"
        case .running: return "路由运行中"
        case .stopping: return "正在停止"
        case .failed(let message): return message
        }
    }
}

final class SystemAudioRouter: NSObject, SCStreamOutput, SCStreamDelegate, @unchecked Sendable {
    private let audioQueue = DispatchQueue(label: "app.bluebridge.capture.audio", qos: .userInteractive)
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var stream: SCStream?
    private var enginePrepared = false

    @MainActor var onStateChange: ((RouterState) -> Void)?

    func start(outputDeviceID: AudioDeviceID) async throws {
        await publish(.starting)
        guard CGPreflightScreenCaptureAccess() || CGRequestScreenCaptureAccess() else {
            await publish(.requestingPermission)
            throw RouterError.permissionRequired
        }

        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let display = content.displays.first else {
            throw RouterError.noDisplay
        }

        try prepareEngine(outputDeviceID: outputDeviceID)

        let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
        let configuration = SCStreamConfiguration()
        configuration.capturesAudio = true
        configuration.excludesCurrentProcessAudio = true
        configuration.sampleRate = 48_000
        configuration.channelCount = 2
        configuration.width = 2
        configuration.height = 2
        configuration.minimumFrameInterval = CMTime(value: 1, timescale: 2)
        configuration.showsCursor = false
        configuration.queueDepth = 3

        let newStream = SCStream(filter: filter, configuration: configuration, delegate: self)
        try newStream.addStreamOutput(self, type: .audio, sampleHandlerQueue: audioQueue)
        stream = newStream
        try await newStream.startCapture()
        await publish(.running)
    }

    func stop() async {
        await publish(.stopping)
        if let stream {
            try? await stream.stopCapture()
        }
        stream = nil
        player.stop()
        engine.stop()
        enginePrepared = false
        await publish(.idle)
    }

    private func prepareEngine(outputDeviceID: AudioDeviceID) throws {
        if enginePrepared {
            player.stop()
            engine.stop()
            engine.detach(player)
            enginePrepared = false
        }

        engine.attach(player)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 2) else {
            throw RouterError.invalidAudioFormat
        }
        engine.connect(player, to: engine.mainMixerNode, format: format)

        var deviceID = outputDeviceID
        guard let audioUnit = engine.outputNode.audioUnit else {
            throw RouterError.outputUnavailable
        }
        let status = AudioUnitSetProperty(
            audioUnit,
            kAudioOutputUnitProperty_CurrentDevice,
            kAudioUnitScope_Global,
            0,
            &deviceID,
            UInt32(MemoryLayout<AudioDeviceID>.size)
        )
        guard status == noErr else { throw RouterError.outputSelectionFailed(status) }

        engine.prepare()
        try engine.start()
        player.play()
        enginePrepared = true
    }

    nonisolated func stream(
        _ stream: SCStream,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
        of outputType: SCStreamOutputType
    ) {
        guard outputType == .audio,
              sampleBuffer.isValid,
              CMSampleBufferDataIsReady(sampleBuffer),
              let description = sampleBuffer.formatDescription,
              let basicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(description)?.pointee
        else { return }

        var asbd = basicDescription
        guard let format = AVAudioFormat(streamDescription: &asbd) else { return }
        let frameCount = AVAudioFrameCount(CMSampleBufferGetNumSamples(sampleBuffer))
        guard frameCount > 0,
              let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        else { return }

        var requiredSize = 0
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: &requiredSize,
            bufferListOut: nil,
            bufferListSize: 0,
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
            blockBufferOut: nil
        )
        guard requiredSize >= MemoryLayout<AudioBufferList>.size else { return }

        let sourceStorage = UnsafeMutableRawPointer.allocate(
            byteCount: requiredSize,
            alignment: MemoryLayout<AudioBufferList>.alignment
        )
        defer { sourceStorage.deallocate() }
        let sourcePointer = sourceStorage.bindMemory(to: AudioBufferList.self, capacity: 1)
        let sourceList = UnsafeMutableAudioBufferListPointer(sourcePointer)
        var retainedBlockBuffer: CMBlockBuffer?
        let status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: sourceList.unsafeMutablePointer,
            bufferListSize: requiredSize,
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
            blockBufferOut: &retainedBlockBuffer
        )
        guard status == noErr else { return }

        pcmBuffer.frameLength = frameCount
        let destinationList = UnsafeMutableAudioBufferListPointer(pcmBuffer.mutableAudioBufferList)
        for index in 0..<min(sourceList.count, destinationList.count) {
            guard let source = sourceList[index].mData,
                  let destination = destinationList[index].mData
            else { continue }
            let byteCount = min(Int(sourceList[index].mDataByteSize), Int(destinationList[index].mDataByteSize))
            memcpy(destination, source, byteCount)
            destinationList[index].mDataByteSize = UInt32(byteCount)
        }
        player.scheduleBuffer(pcmBuffer)
    }

    nonisolated func stream(_ stream: SCStream, didStopWithError error: Error) {
        Task { await publish(.failed(error.localizedDescription)) }
    }

    private func publish(_ state: RouterState) async {
        await MainActor.run { onStateChange?(state) }
    }
}

enum RouterError: LocalizedError {
    case permissionRequired
    case noDisplay
    case invalidAudioFormat
    case outputUnavailable
    case outputSelectionFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .permissionRequired:
            return "请在系统设置中允许“屏幕与系统音频录制”，然后重新打开 BlueBridge。"
        case .noDisplay:
            return "未找到可用于系统音频捕获的显示器。"
        case .invalidAudioFormat:
            return "无法创建 48 kHz 立体声音频路由。"
        case .outputUnavailable:
            return "所选音频输出当前不可用。"
        case .outputSelectionFailed(let status):
            return "CoreAudio 无法选择此输出（\(status)）。"
        }
    }
}
