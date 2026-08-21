import 'package:flutter/material.dart';

class AppTheme {
  // Warna Utama berdasarkan DESIGN.md
  static const Color primary = Color(0xFF064E3B); // Emerald
  static const Color secondary = Color(0xFFD4AF37); // Gold
  static const Color background = Color(0xFFF8FAFC); // Soft White
  static const Color surfaceDark = Color(
    0xFF1E293B,
  ); // Slate/Charcoal untuk Sidebar
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Level 1 Surface
  static const Color error = Color(0xFF991B1B); // Muted Crimson
  static const Color divider = Color(0xFFF1F5F9);

  // Text Styles (Inter)
  static const TextStyle priceDisplay = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: surfaceDark,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5, // 0.05em
    color: Color(0xFF707974),
  );
}
