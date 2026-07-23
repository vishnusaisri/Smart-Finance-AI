import 'package:flutter/material.dart';

class AppGradients {
  // Subtle premium gradients (not childish)
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6), // Blue 500
      Color(0xFF2563EB), // Blue 600
    ],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF06B6D4), // Cyan 500
      Color(0xFF0891B2), // Cyan 600
    ],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981), // Emerald 500
      Color(0xFF059669), // Emerald 600
    ],
  );

  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B), // Amber 500
      Color(0xFFD97706), // Amber 600
    ],
  );

  static const LinearGradient danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444), // Red 500
      Color(0xFFDC2626), // Red 600
    ],
  );

  // Glass effect gradients (very subtle)
  static const LinearGradient glassLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x0AFFFFFF), // 4% white
      Color(0x05FFFFFF), // 2% white
    ],
  );

  static const LinearGradient glassDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x0A000000), // 4% black
      Color(0x05000000), // 2% black
    ],
  );

  // Surface gradients
  static const LinearGradient surfaceElevated = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E293B), // Slate 800
      Color(0xFF0F172A), // Slate 900
    ],
  );

  // Chart gradients
  static const LinearGradient chartArea1 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x403B82F6), // Blue with 25% opacity
      Color(0x003B82F6), // Blue with 0% opacity
    ],
  );

  static const LinearGradient chartArea2 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x4006B6D4), // Cyan with 25% opacity
      Color(0x0006B6D4), // Cyan with 0% opacity
    ],
  );
}
