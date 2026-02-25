import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF111111);
  static const card = Color(0xFF161616);
  static const border = Color(0xFF222222);
  static const borderLight = Color(0xFF2A2A2A);

  static const accent = Color(0xFF6C63FF);
  static const accentDim = Color(0x1A6C63FF);
  static const accentGlow = Color(0x336C63FF);

  static const success = Color(0xFF22C55E);
  static const successDim = Color(0x1A22C55E);
  static const danger = Color(0xFFEF4444);
  static const dangerDim = Color(0x1AEF4444);
  static const warning = Color(0xFFF59E0B);
  static const warningDim = Color(0x1AF59E0B);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF888888);
  static const textTertiary = Color(0xFF444444);

  // Text Styles
  static const headingLarge = TextStyle(
    color: textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  static const headingMedium = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );
  static const bodyMedium = TextStyle(
    color: textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static const bodySmall = TextStyle(
    color: textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
  static const labelSmall = TextStyle(
    color: textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      surface: surface,
      error: danger,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
    ),
  );
}
