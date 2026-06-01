import 'package:flutter/material.dart';

/// Central palette — single source of truth for the dark luxury theme.
abstract final class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceElevated = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF1E1E1E);

  static const Color primary = Color(0xFF32FF4A);
  static const Color primaryDark = Color(0xFF1DB833);
  static const Color primaryGlow = Color(0x6632FF4A);

  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textMuted = Color(0xFF6E6E6E);
  static const Color taglineGold = Color(0xFFC9B896);

  static const Color border = Color(0xFF2A2A2A);
  static const Color borderActive = Color(0xFF32FF4A);
  static const Color glassFill = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);

  static const Color error = Color(0xFFFF5252);
  static const Color onPrimary = Color(0xFF0A0A0A);
}
