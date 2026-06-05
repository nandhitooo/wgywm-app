import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color orange = Color(0xFFF5A623);
  static const Color orangeLight = Color(0xFFFFB84D);
  static const Color orangeDark = Color(0xFFE8940F);
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color accentGreen = Color(0xFF7ED321);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF7F7F7);
  static const Color gray = Color(0xFF888888);
  static const Color dark = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFFEEEEEE);

  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [orange, orangeDark],
      );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ];

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: orange,
          secondary: accentBlue,
          surface: white,
          onSurface: dark,
          background: lightGray,
          onBackground: dark,
          outline: const Color(0xFFE5E5E5),
        ),
        scaffoldBackgroundColor: lightGray,
        textTheme: GoogleFonts.dmSansTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: dark,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: _elevatedButtonTheme,
        inputDecorationTheme: _inputDecorationTheme(Brightness.light),
        cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: white,
        ),
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
          backgroundColor: Colors.transparent,
          foregroundColor: white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: _elevatedButtonTheme,
        inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
        cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFF1A1A1A),
        ),
      );

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
      fillColor: isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFEBEBEB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFEBEBEB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: orange, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.dmSans(
        color: gray,
        fontSize: 14,
      ),
    );
  }

  // Backwards compatibility for now
  static ThemeData get theme => lightTheme;
}
