import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryAccent = Color(0xFFA5B4FC);
  static const Color primaryDark = Color(0xFF4F46E5);

  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF22D3EE);

  static const Color emeraldColor = Color(0xFF10B981);
  static const Color emeraldAccentColor = Color(0xFF34D399);

  static const Color warningColor = Color(0xFFF59E0B);
  static const Color warningAccentColor = Color(0xFFFBBF24);

  static const Color errorColor = Color(0xFFEF4444);
  static const Color errorAccentColor = Color(0xFFF87171);

  // Background & Surface Obsidian Palette
  static const Color background = Color(0xFF0A0A0C);
  static const Color backgroundDark = Color(0xFF08080A);
  static const Color backgroundLight = Color(0xFF0F0F12);
  static const Color surface = Color(0xFF141418);
  static const Color surfaceElevated = Color(0xFF181820);
  static const Color surfaceDark = Color(0xFF0D0D10);
  static const Color border = Color(0xFF24242A);
  static const Color borderSubtle = Color(0xFF1E1E26);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, backgroundDark],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary],
  );

  static const LinearGradient logoGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF06B6D4)],
  );

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
