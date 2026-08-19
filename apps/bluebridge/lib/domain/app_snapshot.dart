import 'package:flutter/foundation.dart';

@immutable
class AppSnapshot {
  const AppSnapshot({
    required this.platformAudioReady,
    required this.outputs,
    required this.devices,
    this.activeRoute,
  });

  static const reset = AppSnapshot(
    platformAudioReady: false,
    outputs: <AudioEndpoint>[],
    devices: <BridgeDevice>[],
  );

  final bool platformAudioReady;
  final List<AudioEndpoint> outputs;
  final List<BridgeDevice> devices;
  final ActiveRoute? activeRoute;
}

@immutable
class AudioEndpoint {
  const AudioEndpoint({required this.id, required this.name});

  final String id;
  final String name;
}

@immutable
class BridgeDevice {
  const BridgeDevice({required this.id, required this.name});

  final String id;
  final String name;
}

@immutable
class ActiveRoute {
  const ActiveRoute({
    required this.source,
    required this.destination,
    required this.output,
  });

  final String source;
  final String destination;
  final String output;
}
