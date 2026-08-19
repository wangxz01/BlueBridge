import 'package:flutter/material.dart';

import 'domain/app_snapshot.dart';
import 'ui/bluebridge_home.dart';
import 'ui/bluebridge_theme.dart';

class BlueBridgeApp extends StatelessWidget {
  const BlueBridgeApp({super.key, this.snapshot = AppSnapshot.reset});

  final AppSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlueBridge',
      debugShowCheckedModeBanner: false,
      theme: buildBlueBridgeTheme(),
      home: BlueBridgeHome(snapshot: snapshot),
    );
  }
}
