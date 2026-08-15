package app.bluebridge.android

import android.media.projection.MediaProjection

interface PlatformAudio {
    suspend fun listOutputs(): List<String>
    suspend fun startPlaybackCapture(mediaProjection: MediaProjection)
    suspend fun startSink(routeId: String)
    suspend fun stop()
}

/**
 * Explicit development adapter. Production work must create an
 * AudioPlaybackCaptureConfiguration from user-approved MediaProjection,
 * respect per-application capture policy, and render the final mix through
 * AudioTrack while following Android's current system output route.
 */
class DevelopmentPlatformAudio : PlatformAudio {
    override suspend fun listOutputs() = listOf("System route", "Bluetooth headset", "USB-C audio")
    override suspend fun startPlaybackCapture(mediaProjection: MediaProjection) = Unit
    override suspend fun startSink(routeId: String) = Unit
    override suspend fun stop() = Unit
}
