package app.bluebridge.android

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel

class BlueBridgeViewModel : ViewModel() {
    var session by mutableStateOf(
        RouteSession(
            name = "图书馆",
            source = "MacBook Air",
            sink = "本机 Pixel 9",
            output = "Pixel Buds Pro",
            link = "手机热点",
            latencyMs = 21,
            running = true,
        )
    )
        private set

    var status by mutableStateOf("仅在本地设备间处理，不上传音频")
        private set

    val devices = mutableStateListOf(
        BridgeDevice("pixel", "本机 Pixel 9", "Android", "混音输出 · 系统路由"),
        BridgeDevice("mac", "MacBook Air", "macOS", "局域网来源 · 21 ms"),
        BridgeDevice("pc", "游戏电脑", "Windows", "可信设备 · 28 ms"),
    )

    val sources = mutableStateListOf(
        MixerSource("mac-system", "MacBook Air · 系统音频", "手机热点", 0.72f),
        MixerSource("android-local", "本机 · 媒体", "本机", 0.76f),
    )

    fun toggleRoute() {
        session = session.copy(running = !session.running)
        status = if (session.running) "路由已恢复，正在使用最佳本地链路" else "路由已停止，配置已保留"
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
            BuiltInPreset.GamingStudy -> RouteSession("游戏 + 学习", "本机 Pixel 9", "游戏电脑", "2.4G 耳机", "标准蓝牙", 38, true)
            BuiltInPreset.Library -> RouteSession("图书馆", "MacBook Air", "本机 Pixel 9", "Pixel Buds Pro", "手机热点", 21, true)
        }
        status = "场景已启动，自动重连已开启"
    }

    fun scan() {
        status = "正在扫描局域网和蓝牙设备…"
    }
}
