import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors from MASAR SMART logo
  static const Color primaryBlue = Color(0xFF1E3A5F);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color accentYellow = Color(0xFFFFB800);
  static const Color lightBlue = Color(0xFF3D5A80);
  static const Color backgroundWhite = Color(0xFFFAFAFA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF22C55E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryGreen,
        tertiary: accentYellow,
        surface: backgroundWhite,
        error: errorRed,
      ),
      scaffoldBackgroundColor: backgroundWhite,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
