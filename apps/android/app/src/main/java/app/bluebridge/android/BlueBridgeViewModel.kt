package app.bluebridge.android

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel

class BlueBridgeViewModel : ViewModel() {
    var session by mutableStateOf(
        RouteSession(
            name = "Library",
            source = "MacBook Air",
            sink = "This Pixel 9",
            output = "Pixel Buds Pro",
            link = "Phone hotspot",
            latencyMs = 21,
            running = true,
        )
    )
        private set

    var status by mutableStateOf("Local audio only — nothing is uploaded")
        private set

    val devices = mutableStateListOf(
        BridgeDevice("pixel", "This Pixel 9", "Android", "Mix hub · system output"),
        BridgeDevice("mac", "MacBook Air", "macOS", "LAN source · 21 ms"),
        BridgeDevice("pc", "Gaming PC", "Windows", "Trusted · 28 ms"),
    )

    val sources = mutableStateListOf(
        MixerSource("mac-system", "MacBook Air · System", "Phone hotspot", 0.72f),
        MixerSource("android-local", "This phone · Media", "Local", 0.76f),
    )

    fun toggleRoute() {
        session = session.copy(running = !session.running)
        status = if (session.running) "Route restored · best local link selected" else "Route stopped · configuration preserved"
    }

    fun updateVolume(id: String, volume: Float) {
        val index = sources.indexOfFirst { it.id == id }
        if (index >= 0) sources[index] = sources[index].copy(volume = volume.coerceIn(0f, 1f))
    }

    fun toggleMute(id: String) {
        val index = sources.indexOfFirst { it.id == id }
        if (index >= 0) sources[index] = sources[index].copy(muted = !sources[index].muted)
    }

    fun startPreset(preset: BuiltInPreset) {
        session = when (preset) {
            BuiltInPreset.GamingStudy -> RouteSession("Gaming + Study", "This Pixel 9", "Gaming PC", "2.4G headset", "Standard Bluetooth", 38, true)
            BuiltInPreset.Library -> RouteSession("Library", "MacBook Air", "This Pixel 9", "Pixel Buds Pro", "Phone hotspot", 21, true)
        }
        status = "Preset started · reconnect policy active"
    }

    fun scan() {
        status = "Scanning the local network and Bluetooth…"
    }
}
