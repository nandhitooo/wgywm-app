import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color orange = Color(0xFFF5A623);
  static const Color darkOrange = Color(0xFFE8940F);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF7F7F7);
  static const Color gray = Color(0xFF888888);
  static const Color dark = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFFEEEEEE);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: orange,
          surface: white,
          onSurface: dark,
          background: lightGray,
          onBackground: dark,
        ),
        scaffoldBackgroundColor: lightGray,
        textTheme: GoogleFonts.dmSansTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: orange,
          foregroundColor: white,
          elevation: 0,
        ),
        elevatedButtonTheme: _elevatedButtonTheme,
        inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          brightness: Brightness.dark,
          primary: orange,
          secondary: orange,
          surface: const Color(0xFF1A1A1A),
          onSurface: const Color(0xFFE1E1E1),
          background: const Color(0xFF0F0F0F),
          onBackground: const Color(0xFFE1E1E1),
          surfaceVariant: const Color(0xFF252525),
          outline: const Color(0xFF333333),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        dividerColor: const Color(0xFF333333),
        textTheme: GoogleFonts.dmSansTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ).apply(
          bodyColor: const Color(0xFFE1E1E1),
          displayColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: _elevatedButtonTheme,
        inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      );

  static ElevatedButtonThemeData get _elevatedButtonTheme => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF3E3E3E) : const Color(0xFFE5E5E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF3E3E3E) : const Color(0xFFE5E5E5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: orange, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.dmSans(
        color: gray,
        fontSize: 14,
      ),
    );
  }

  // Backwards compatibility for now
  static ThemeData get theme => lightTheme;
}
