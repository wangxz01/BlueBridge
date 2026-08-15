package app.bluebridge.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.weight
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel

private val Ink = Color(0xFF171717)
private val Canvas = Color(0xFFF4F4F2)
private val Surface = Color.White
private val Line = Color(0xFFDDDDD8)
private val Muted = Color(0xFF6B6B67)
private val StatusGreen = Color(0xFF2E7D4F)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent { MaterialTheme { BlueBridgeApp() } }
    }
}

@Composable
fun BlueBridgeApp(model: BlueBridgeViewModel = viewModel()) {
    var page by remember { mutableIntStateOf(0) }
    val pages = listOf("路由", "设备", "场景", "设置")

    Scaffold(
        containerColor = Canvas,
        bottomBar = {
            NavigationBar(containerColor = Ink) {
                pages.forEachIndexed { index, label ->
                    NavigationBarItem(
                        selected = page == index,
                        onClick = { page = index },
                        icon = { Text(listOf("01", "02", "03", "04")[index], fontSize = 10.sp, color = if (page == index) Ink else Color.White.copy(alpha = .55f)) },
                        label = { Text(label, fontSize = 10.sp, color = if (page == index) Color.White else Color.White.copy(alpha = .6f)) },
                        colors = NavigationBarItemDefaults.colors(indicatorColor = Surface),
                    )
                }
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding).padding(horizontal = 18.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            item { Header(pages[page], model.status) }
            when (page) {
                0 -> {
                    item { RouteCard(model.session, model::toggleRoute) }
                    item { SectionTitle("混音", "每一路声音可独立调整") }
                    items(model.sources, key = { it.id }) { source ->
                        MixerRow(source, { model.updateVolume(source.id, it) }, { model.toggleMute(source.id) })
                    }
                    item { SectionTitle("可信设备", "附近且可以自动重连") }
                    items(model.devices, key = { it.id }) { DeviceRow(it) }
                }
                1 -> {
                    item { SectionTitle("设备列表", "首次连接需要在两台设备上确认") }
                    items(model.devices, key = { it.id }) { DeviceRow(it) }
                    item { PrimaryButton("扫描附近设备", model::scan) }
                }
                2 -> item { Presets(model::startPreset) }
                3 -> items(listOf("自动重连", "自动选择最佳链路", "音频回环保护")) { SettingRow(it) }
            }
            item { Spacer(Modifier.height(8.dp)) }
        }
    }
}

@Composable
private fun Header(title: String, status: String) {
    Column(Modifier.padding(top = 26.dp, bottom = 6.dp)) {
        Text(title, color = Ink, fontSize = 28.sp, fontWeight = FontWeight.Bold)
        Text(status, color = Muted, fontSize = 12.sp)
    }
}

@Composable
private fun RouteCard(session: RouteSession, onToggle: () -> Unit) {
    SurfaceCard {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column {
                Text("当前路由", color = Muted, fontSize = 10.sp)
                Text(session.name, color = Ink, fontSize = 20.sp, fontWeight = FontWeight.SemiBold)
            }
            Spacer(Modifier.weight(1f))
            Button(onClick = onToggle, colors = ButtonDefaults.buttonColors(containerColor = Ink, contentColor = Color.White)) {
                Text(if (session.running) "停止" else "恢复")
            }
        }

        Spacer(Modifier.height(18.dp))
        RouteInfo("01", "来源", session.source)
        RouteArrow()
        RouteInfo("02", "目标", session.sink)
        RouteArrow()
        RouteInfo("03", "输出", session.output)
        Spacer(Modifier.height(16.dp))

        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(7.dp).background(if (session.running) StatusGreen else Muted, CircleShape))
            Text(if (session.running) " 运行中" else " 已暂停", color = if (session.running) StatusGreen else Muted, fontSize = 11.sp)
            Spacer(Modifier.weight(1f))
            Text("${session.link} · ${session.latencyMs} ms · 48 kHz", color = Muted, fontSize = 10.sp)
        }
    }
}

@Composable
private fun RouteInfo(index: String, label: String, value: String) {
    Row(Modifier.fillMaxWidth().background(Canvas, RoundedCornerShape(8.dp)).padding(13.dp), verticalAlignment = Alignment.CenterVertically) {
        Text(index, color = Muted, fontSize = 10.sp)
        Text(label, color = Muted, fontSize = 10.sp, modifier = Modifier.padding(start = 8.dp))
        Spacer(Modifier.weight(1f))
        Text(value, color = Ink, fontSize = 13.sp, fontWeight = FontWeight.Medium)
    }
}

@Composable
private fun RouteArrow() { Text("↓", color = Muted, modifier = Modifier.padding(start = 16.dp, top = 3.dp, bottom = 3.dp)) }

@Composable
private fun SectionTitle(title: String, detail: String) {
    Column(Modifier.padding(top = 8.dp)) {
        Text(title, color = Ink, fontSize = 17.sp, fontWeight = FontWeight.SemiBold)
        Text(detail, color = Muted, fontSize = 11.sp)
    }
}

@Composable
private fun MixerRow(source: MixerSource, onVolume: (Float) -> Unit, onMute: () -> Unit) {
    SurfaceCard {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text(source.name, color = Ink, fontWeight = FontWeight.Medium)
                Text(source.detail, color = Muted, fontSize = 10.sp)
            }
            TextButton(onClick = onMute) { Text(if (source.muted) "取消静音" else "静音", color = Ink, fontSize = 11.sp) }
        }
        Slider(value = source.volume, onValueChange = onVolume)
    }
}

@Composable
private fun DeviceRow(device: BridgeDevice) {
    SurfaceCard {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text(device.name, color = Ink, fontWeight = FontWeight.Medium)
                Text("${device.platform} · ${device.detail}", color = Muted, fontSize = 10.sp)
            }
            Box(Modifier.size(7.dp).background(if (device.isOnline) StatusGreen else Muted, CircleShape))
            Text(if (device.isOnline) " 在线" else " 离线", color = if (device.isOnline) StatusGreen else Muted, fontSize = 10.sp)
        }
    }
}

@Composable
private fun Presets(onStart: (BuiltInPreset) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        SectionTitle("场景", "一键恢复来源、输出和音量")
        PresetRow("游戏 + 学习", "手机 → Windows → 2.4G 耳机") { onStart(BuiltInPreset.GamingStudy) }
        PresetRow("图书馆", "Mac → Android → 蓝牙耳机") { onStart(BuiltInPreset.Library) }
    }
}

@Composable
private fun PresetRow(name: String, route: String, onStart: () -> Unit) {
    SurfaceCard {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text(name, color = Ink, fontWeight = FontWeight.SemiBold)
                Text(route, color = Muted, fontSize = 10.sp)
            }
            Button(onClick = onStart, colors = ButtonDefaults.buttonColors(containerColor = Ink, contentColor = Color.White)) { Text("启动") }
        }
    }
}

@Composable
private fun SettingRow(name: String) {
    SurfaceCard {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(name, color = Ink, fontWeight = FontWeight.Medium)
            Spacer(Modifier.weight(1f))
            Text("已开启", color = StatusGreen, fontSize = 11.sp)
        }
    }
}

@Composable
private fun PrimaryButton(label: String, onClick: () -> Unit) {
    Button(onClick = onClick, colors = ButtonDefaults.buttonColors(containerColor = Ink, contentColor = Color.White), modifier = Modifier.fillMaxWidth()) {
        Text(label, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
private fun SurfaceCard(content: @Composable ColumnScope.() -> Unit) {
    Card(
        colors = CardDefaults.cardColors(containerColor = Surface),
        shape = RoundedCornerShape(12.dp),
        modifier = Modifier.fillMaxWidth().border(1.dp, Line, RoundedCornerShape(12.dp)),
    ) { Column(Modifier.padding(16.dp), content = content) }
}

@Preview(showBackground = true, widthDp = 390, heightDp = 844)
@Composable
private fun PreviewBlueBridge() { MaterialTheme { BlueBridgeApp(BlueBridgeViewModel()) } }
