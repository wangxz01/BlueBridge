//! Shared product model for the three BlueBridge native clients.
//!
//! This crate deliberately contains no UI or platform audio APIs. Windows,
//! macOS and Android adapters translate native devices and sessions into these
//! types, keeping route validation and recovery behavior consistent.

use std::collections::{HashMap, HashSet};
use std::fmt;

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub struct DeviceId(String);

impl DeviceId {
    pub fn new(value: impl Into<String>) -> Result<Self, ModelError> {
        let value = value.into();
        if value.trim().is_empty() {
            return Err(ModelError::EmptyIdentifier);
        }
        Ok(Self(value))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Platform {
    Windows,
    MacOs,
    Android,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Capability {
    SendSystemAudio,
    ReceiveBlueBridgeAudio,
    LanTransport,
    BlueBridgeBluetooth,
    StandardA2dpReceiver,
    MultiSourceMix,
    SelectOutputDevice,
    CaptureApplication,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum TrustState {
    PendingConfirmation,
    Trusted,
    Blocked,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Device {
    pub id: DeviceId,
    pub name: String,
    pub platform: Platform,
    pub trust: TrustState,
    pub online: bool,
    pub capabilities: HashSet<Capability>,
}

impl Device {
    pub fn supports(&self, capability: Capability) -> bool {
        self.capabilities.contains(&capability)
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SourceKind {
    System,
    Application,
    StandardBluetooth,
    BlueBridgeRemote,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct AudioSource {
    pub id: String,
    pub device_id: DeviceId,
    pub name: String,
    pub kind: SourceKind,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct AudioOutput {
    pub id: String,
    pub device_id: DeviceId,
    pub name: String,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Transport {
    Local,
    Lan,
    PhoneHotspot,
    StandardBluetooth,
    BlueBridgeBluetooth,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum QualityPreference {
    LowLatency,
    Balanced,
    Stable,
    HighQuality,
}

#[derive(Clone, Debug, PartialEq)]
pub struct MixerChannel {
    pub source_id: String,
    pub volume: f32,
    pub muted: bool,
}

impl MixerChannel {
    pub fn new(source_id: impl Into<String>, volume: f32) -> Self {
        Self {
            source_id: source_id.into(),
            volume: volume.clamp(0.0, 1.0),
            muted: false,
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct RoutePlan {
    pub id: String,
    pub name: String,
    pub sink_device_id: DeviceId,
    pub output_id: String,
    pub channels: Vec<MixerChannel>,
    pub transport_preference: Vec<Transport>,
    pub quality: QualityPreference,
    pub auto_reconnect: bool,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Preset {
    pub id: String,
    pub name: String,
    pub route: RoutePlan,
}

impl Preset {
    pub fn gaming_and_study(windows: DeviceId) -> Self {
        Self {
            id: "gaming-study".into(),
            name: "Gaming + Study".into(),
            route: RoutePlan {
                id: "gaming-study-route".into(),
                name: "Gaming + Study".into(),
                sink_device_id: windows,
                output_id: "system-default".into(),
                channels: vec![
                    MixerChannel::new("windows-system", 0.82),
                    MixerChannel::new("standard-bluetooth", 0.64),
                ],
                transport_preference: vec![Transport::Local, Transport::StandardBluetooth],
                quality: QualityPreference::LowLatency,
                auto_reconnect: true,
            },
        }
    }

    pub fn library(android: DeviceId) -> Self {
        Self {
            id: "library".into(),
            name: "Library".into(),
            route: RoutePlan {
                id: "library-route".into(),
                name: "Library".into(),
                sink_device_id: android,
                output_id: "android-system-route".into(),
                channels: vec![
                    MixerChannel::new("mac-system", 0.72),
                    MixerChannel::new("android-local", 0.72),
                ],
                transport_preference: vec![
                    Transport::Lan,
                    Transport::PhoneHotspot,
                    Transport::BlueBridgeBluetooth,
                ],
                quality: QualityPreference::Balanced,
                auto_reconnect: true,
            },
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SessionState {
    Idle,
    Connecting,
    Running,
    Recovering,
    Stopped,
    Failed,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Session {
    pub route: RoutePlan,
    pub state: SessionState,
    pub selected_transport: Option<Transport>,
    pub estimated_latency_ms: Option<u32>,
    pub recovery_attempt: u8,
}

impl Session {
    pub fn begin(route: RoutePlan) -> Self {
        Self {
            route,
            state: SessionState::Connecting,
            selected_transport: None,
            estimated_latency_ms: None,
            recovery_attempt: 0,
        }
    }

    pub fn connected(&mut self, transport: Transport, latency_ms: u32) {
        self.state = SessionState::Running;
        self.selected_transport = Some(transport);
        self.estimated_latency_ms = Some(latency_ms);
        self.recovery_attempt = 0;
    }

    pub fn connection_lost(&mut self) {
        self.state = if self.route.auto_reconnect {
            SessionState::Recovering
        } else {
            SessionState::Failed
        };
    }

    pub fn next_retry_delay_ms(&mut self) -> Option<u64> {
        if self.state != SessionState::Recovering || self.recovery_attempt >= 8 {
            return None;
        }
        let delay = (500_u64.saturating_mul(1_u64 << self.recovery_attempt)).min(30_000);
        self.recovery_attempt += 1;
        Some(delay)
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum ModelError {
    EmptyIdentifier,
    EmptyRouteName,
    NoSources,
    UnknownSink,
    UnknownSource(String),
    UntrustedDevice(String),
    OfflineDevice(String),
    DuplicateSource(String),
    AudioLoop(String),
    UnsupportedSink,
}

impl fmt::Display for ModelError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(formatter, "{self:?}")
    }
}

impl std::error::Error for ModelError {}

pub fn validate_route(
    route: &RoutePlan,
    devices: &HashMap<DeviceId, Device>,
    sources: &HashMap<String, AudioSource>,
) -> Result<(), ModelError> {
    if route.name.trim().is_empty() {
        return Err(ModelError::EmptyRouteName);
    }
    if route.channels.is_empty() {
        return Err(ModelError::NoSources);
    }

    let sink = devices
        .get(&route.sink_device_id)
        .ok_or(ModelError::UnknownSink)?;
    if sink.trust != TrustState::Trusted {
        return Err(ModelError::UntrustedDevice(sink.name.clone()));
    }
    if !sink.online {
        return Err(ModelError::OfflineDevice(sink.name.clone()));
    }
    if !sink.supports(Capability::MultiSourceMix) {
        return Err(ModelError::UnsupportedSink);
    }

    let mut seen = HashSet::new();
    for channel in &route.channels {
        if !seen.insert(&channel.source_id) {
            return Err(ModelError::DuplicateSource(channel.source_id.clone()));
        }
        let source = sources
            .get(&channel.source_id)
            .ok_or_else(|| ModelError::UnknownSource(channel.source_id.clone()))?;
        let source_device = devices
            .get(&source.device_id)
            .ok_or_else(|| ModelError::UnknownSource(channel.source_id.clone()))?;
        if source_device.trust != TrustState::Trusted {
            return Err(ModelError::UntrustedDevice(source_device.name.clone()));
        }
        if source.kind == SourceKind::BlueBridgeRemote && source.device_id == route.sink_device_id {
            return Err(ModelError::AudioLoop(channel.source_id.clone()));
        }
    }

    Ok(())
}

pub fn choose_transport(
    preferences: &[Transport],
    available: &HashSet<Transport>,
) -> Option<Transport> {
    preferences
        .iter()
        .copied()
        .find(|transport| available.contains(transport))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn device(id: &str, platform: Platform) -> Device {
        Device {
            id: DeviceId::new(id).unwrap(),
            name: id.into(),
            platform,
            trust: TrustState::Trusted,
            online: true,
            capabilities: HashSet::from([
                Capability::ReceiveBlueBridgeAudio,
                Capability::MultiSourceMix,
            ]),
        }
    }

    #[test]
    fn chooses_first_available_transport_in_preference_order() {
        let available = HashSet::from([Transport::BlueBridgeBluetooth, Transport::PhoneHotspot]);
        let chosen = choose_transport(
            &[
                Transport::Lan,
                Transport::PhoneHotspot,
                Transport::BlueBridgeBluetooth,
            ],
            &available,
        );
        assert_eq!(chosen, Some(Transport::PhoneHotspot));
    }

    #[test]
    fn blocks_a_remote_source_from_looping_back_into_its_own_sink() {
        let android = device("android", Platform::Android);
        let devices = HashMap::from([(android.id.clone(), android.clone())]);
        let sources = HashMap::from([(
            "loop".into(),
            AudioSource {
                id: "loop".into(),
                device_id: android.id.clone(),
                name: "BlueBridge monitor".into(),
                kind: SourceKind::BlueBridgeRemote,
            },
        )]);
        let route = RoutePlan {
            id: "route".into(),
            name: "Loop".into(),
            sink_device_id: android.id,
            output_id: "speaker".into(),
            channels: vec![MixerChannel::new("loop", 1.0)],
            transport_preference: vec![Transport::Lan],
            quality: QualityPreference::Balanced,
            auto_reconnect: true,
        };

        assert_eq!(
            validate_route(&route, &devices, &sources),
            Err(ModelError::AudioLoop("loop".into()))
        );
    }

    #[test]
    fn recovery_uses_bounded_exponential_backoff() {
        let android = DeviceId::new("android").unwrap();
        let mut session = Session::begin(Preset::library(android).route);
        session.connected(Transport::Lan, 21);
        session.connection_lost();

        let delays: Vec<_> = (0..8)
            .map(|_| session.next_retry_delay_ms().unwrap())
            .collect();
        assert_eq!(
            delays,
            vec![500, 1_000, 2_000, 4_000, 8_000, 16_000, 30_000, 30_000]
        );
        assert_eq!(session.next_retry_delay_ms(), None);
    }

    #[test]
    fn mixer_volume_is_clamped() {
        assert_eq!(MixerChannel::new("source", 1.5).volume, 1.0);
        assert_eq!(MixerChannel::new("source", -1.0).volume, 0.0);
    }
}
