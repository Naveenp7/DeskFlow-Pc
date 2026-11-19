import 'package:flutter/material.dart';

class AppTheme {
  // Backgrounds — true OLED black base with a neutral (non-blue-tinted) panel
  // system, closer to iOS StandBy than the old blue-black "cyberpunk" look.
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121214);
  static const Color surfaceCard = Color(0xFF1A1A20);
  static const Color surfaceElevated = Color(0xFF202024);

  // Panel system used by the desk-deck cards (standby screen & widgets)
  static const Color panel = Color(0xFF15151B);
  static const Color panelBorder = Color(0xFF26262E);
  static const Color tileBg = Color(0xFF1A1A20);

  // Accents — refined iOS-style palette
  static const Color cyan = Color(0xFF0A84FF);
  static const Color purple = Color(0xFFBF5AF2);
  static const Color emerald = Color(0xFF30D158);
  static const Color amber = Color(0xFFFFD60A);
  static const Color standbyOrange = Color(0xFFFF9F0A);
  static const Color rose = Color(0xFFFF453A);
  static const Color blue = Color(0xFF64D2FF);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Borders & Dividers
  static const Color border = Color(0x1FFFFFFF);
  static const Color borderGlow = Color(0x330A84FF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: cyan,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: purple,
        surface: surface,
        surfaceContainerHighest: surfaceCard,
        error: rose,
      ),
      fontFamily: 'Segoe UI',
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
