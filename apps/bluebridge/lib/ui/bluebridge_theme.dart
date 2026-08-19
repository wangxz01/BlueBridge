import 'package:flutter/material.dart';

const ink = Color(0xFF171717);
const canvas = Color(0xFFF5F5F3);
const surface = Color(0xFFFFFFFF);
const line = Color(0xFFE0E0DC);
const muted = Color(0xFF6B6B67);

ThemeData buildBlueBridgeTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: ink,
    brightness: Brightness.light,
    primary: ink,
    onPrimary: Colors.white,
    surface: surface,
    onSurface: ink,
    outline: line,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: canvas,
    dividerColor: line,
    splashFactory: NoSplash.splashFactory,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: ink,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        color: ink,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: ink,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(color: ink, fontSize: 14, height: 1.45),
      bodySmall: TextStyle(color: muted, fontSize: 12, height: 1.4),
      labelMedium: TextStyle(
        color: muted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFE5E5E1),
        disabledForegroundColor: const Color(0xFF8B8B86),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
