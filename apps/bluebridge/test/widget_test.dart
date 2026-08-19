import 'package:bluebridge/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('重置界面只显示真实空状态', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BlueBridgeApp());
    await tester.pumpAndSettle();

    expect(find.text('控制中心'), findsOneWidget);
    expect(find.text('尚未接入'), findsOneWidget);
    expect(find.text('未启动'), findsOneWidget);
    expect(find.textContaining('模拟设备'), findsOneWidget);
    expect(find.textContaining('Pixel'), findsNothing);
    expect(find.textContaining('ms'), findsNothing);
  });

  testWidgets('可以进入路由空状态', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BlueBridgeApp());
    await tester.tap(find.text('路由').first);
    await tester.pumpAndSettle();

    expect(find.text('暂无路由'), findsOneWidget);
    expect(find.textContaining('真实路由'), findsOneWidget);
  });
}
