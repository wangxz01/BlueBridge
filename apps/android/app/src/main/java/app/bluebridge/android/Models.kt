package app.bluebridge.android

import androidx.compose.runtime.Immutable

@Immutable
data class BridgeDevice(
    val id: String,
    val name: String,
    val platform: String,
    val detail: String,
    val isOnline: Boolean = true,
    val isTrusted: Boolean = true,
)

@Immutable
data class MixerSource(
    val id: String,
    val name: String,
    val detail: String,
    val volume: Float,
    val muted: Boolean = false,
)

@Immutable
data class RouteSession(
    val name: String,
    val source: String,
    val sink: String,
    val output: String,
    val link: String,
    val latencyMs: Int,
    val running: Boolean,
)

enum class BuiltInPreset { GamingStudy, Library }
