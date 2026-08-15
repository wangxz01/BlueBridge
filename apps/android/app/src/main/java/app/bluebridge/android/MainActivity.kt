package app.bluebridge.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
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

private val DeepTeal = Color(0xFF123439)
private val Lime = Color(0xFFD9FF75)
private val Canvas = Color(0xFFEEF1EC)

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
    Scaffold(
        containerColor = Canvas,
        bottomBar = {
            NavigationBar(containerColor = DeepTeal) {
                listOf("Overview", "Devices", "Presets", "Settings").forEachIndexed { index, label ->
                    NavigationBarItem(
                        selected = page == index,
                        onClick = { page = index },
                        icon = { Text(listOf("▦", "◇", "✦", "⚙")[index], color = if (page == index) DeepTeal else Color.White) },
                        label = { Text(label, color = if (page == index) Lime else Color.White.copy(alpha = .68f), fontSize = 10.sp) },
                        colors = androidx.compose.material3.NavigationBarItemDefaults.colors(indicatorColor = Lime),
                    )
                }
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding).padding(horizontal = 18.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            item { Header(model.status) }
            if (page == 0) {
                item { RouteCard(model.session, model::toggleRoute) }
                item { SectionTitle("Live mixer", "Mix local and remote audio independently") }
                items(model.sources, key = { it.id }) { source -> MixerCard(source, { model.updateVolume(source.id, it) }, { model.toggleMute(source.id) }) }
                item { SectionTitle("Trusted devices", "Nearby and ready to reconnect") }
                items(model.devices, key = { it.id }) { DeviceCard(it) }
                item { Presets(model::startPreset) }
            } else if (page == 1) {
                item { SectionTitle("All trusted devices", "First connection requires confirmation on both devices") }
                items(model.devices, key = { it.id }) { DeviceCard(it) }
                item { Button(onClick = model::scan, colors = ButtonDefaults.buttonColors(containerColor = Lime, contentColor = DeepTeal), modifier = Modifier.fillMaxWidth()) { Text("Pair a new device", fontWeight = FontWeight.Bold) } }
            } else if (page == 2) {
                item { Presets(model::startPreset) }
            } else {
                items(listOf("Auto reconnect", "Choose the best local link", "Audio loop protection")) { setting ->
                    Card(colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = .8f)), shape = RoundedCornerShape(18.dp)) {
                        Row(Modifier.fillMaxWidth().padding(18.dp), verticalAlignment = Alignment.CenterVertically) { Text(setting, fontWeight = FontWeight.SemiBold); Spacer(Modifier.weight(1f)); Text("ON", color = DeepTeal, fontWeight = FontWeight.Bold) }
                    }
                }
            }
            item { Spacer(Modifier.height(8.dp)) }
        }
    }
}

@Composable
private fun Header(status: String) {
    Column(Modifier.padding(top = 26.dp, bottom = 5.dp)) {
        Text("BlueBridge", color = DeepTeal, fontSize = 30.sp, fontWeight = FontWeight.Bold)
        Text(status, color = Color(0xFF6D797D), fontSize = 12.sp)
    }
}

@Composable
private fun RouteCard(session: RouteSession, onToggle: () -> Unit) {
    Card(colors = CardDefaults.cardColors(containerColor = DeepTeal), shape = RoundedCornerShape(26.dp)) {
        Column(Modifier.padding(22.dp), verticalArrangement = Arrangement.spacedBy(20.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column { Text(if (session.running) "LIVE ROUTE" else "PAUSED", color = Lime, fontSize = 10.sp, fontWeight = FontWeight.Bold); Text(session.name, color = Color.White, fontSize = 21.sp, fontWeight = FontWeight.Bold) }
                Spacer(Modifier.weight(1f)); TextButton(onClick = onToggle) { Text(if (session.running) "Stop" else "Resume", color = Color.White) }
            }
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                RouteNode("▱", session.source, "Source")
                Text("━━", color = Lime)
                RouteNode("▯", session.sink, "Mix hub")
                Text("━━", color = Lime)
                RouteNode("⌾", session.output, "Output")
            }
            Text("↯ ${session.latencyMs} ms   ◎ ${session.link}   48 kHz", color = Color.White.copy(alpha = .64f), fontSize = 10.sp)
        }
    }
}

@Composable
private fun RouteNode(symbol: String, name: String, detail: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.size(width = 86.dp, height = 90.dp)) {
        Box(Modifier.size(48.dp).background(Color.White.copy(alpha = .1f), RoundedCornerShape(15.dp)), contentAlignment = Alignment.Center) { Text(symbol, color = Color.White, fontSize = 21.sp) }
        Text(name, color = Color.White, fontSize = 10.sp, fontWeight = FontWeight.SemiBold, maxLines = 1)
        Text(detail, color = Color.White.copy(alpha = .5f), fontSize = 8.sp)
    }
}

@Composable
private fun SectionTitle(title: String, detail: String) {
    Column(Modifier.padding(top = 9.dp)) { Text(title, color = DeepTeal, fontSize = 18.sp, fontWeight = FontWeight.Bold); Text(detail, color = Color(0xFF6D797D), fontSize = 11.sp) }
}

@Composable
private fun MixerCard(source: MixerSource, onVolume: (Float) -> Unit, onMute: () -> Unit) {
    Card(colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = .8f)), shape = RoundedCornerShape(18.dp)) {
        Column(Modifier.padding(17.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) { Text(source.name, fontWeight = FontWeight.SemiBold); Spacer(Modifier.weight(1f)); TextButton(onClick = onMute) { Text(if (source.muted) "Unmute" else "Mute", color = DeepTeal, fontSize = 11.sp) } }
            Slider(value = source.volume, onValueChange = onVolume)
            Text(source.detail, color = Color(0xFF6D797D), fontSize = 10.sp)
        }
    }
}

@Composable
private fun DeviceCard(device: BridgeDevice) {
    Card(colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = .8f)), shape = RoundedCornerShape(18.dp)) {
        Row(Modifier.fillMaxWidth().padding(17.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(44.dp).background(Color(0xFFE8F1E8), RoundedCornerShape(14.dp)), contentAlignment = Alignment.Center) { Text("◇", color = DeepTeal, fontSize = 20.sp) }
            Column(Modifier.padding(start = 13.dp)) { Text(device.name, fontWeight = FontWeight.SemiBold); Text("${device.platform} · ${device.detail}", color = Color(0xFF6D797D), fontSize = 10.sp) }
            Spacer(Modifier.weight(1f)); Box(Modifier.size(7.dp).background(if (device.isOnline) Color(0xFF72B849) else Color.Gray, CircleShape))
        }
    }
}

@Composable
private fun Presets(onStart: (BuiltInPreset) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        SectionTitle("Presets", "Restore a complete route in one tap")
        listOf(
            Triple("Gaming + Study", "Phone → Windows → 2.4G", BuiltInPreset.GamingStudy),
            Triple("Library", "Mac → Android → headphones", BuiltInPreset.Library),
        ).forEach { (name, route, preset) ->
            Card(colors = CardDefaults.cardColors(containerColor = if (preset == BuiltInPreset.GamingStudy) DeepTeal else Color.White), shape = RoundedCornerShape(18.dp)) {
                Row(Modifier.fillMaxWidth().padding(18.dp), verticalAlignment = Alignment.CenterVertically) {
                    Column { Text(name, color = if (preset == BuiltInPreset.GamingStudy) Color.White else DeepTeal, fontWeight = FontWeight.Bold); Text(route, color = if (preset == BuiltInPreset.GamingStudy) Color.White.copy(alpha = .6f) else Color.Gray, fontSize = 10.sp) }
                    Spacer(Modifier.weight(1f)); Button(onClick = { onStart(preset) }, colors = ButtonDefaults.buttonColors(containerColor = Lime, contentColor = DeepTeal)) { Text("▶") }
                }
            }
        }
    }
}

@Preview(showBackground = true, widthDp = 390, heightDp = 844)
@Composable
private fun PreviewBlueBridge() { MaterialTheme { BlueBridgeApp(BlueBridgeViewModel()) } }
