import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant electric color palette
  static const primaryColor = Color(0xFF005CFF);    // Electric Blue
  static const secondaryColor = Color(0xFF00E5FF);  // Cyan
  static const accentOrange = Color(0xFFFF6D00);    // Vivid Orange
  static const accentPink = Color(0xFFFF007F);      // Neon Pink
  static const accentPurple = Color(0xFF8A2BE2);    // Electric Purple
  static const accentTeal = Color(0xFF1DE9B6);      // Neon Teal
  static const accentIndigo = Color(0xFF3D5AFE);    // Deep Indigo
  static const accentMint = Color(0xFF00E676);      // Neon Mint
  static const accentRed = Color(0xFFFF1744);       // Vivid Red

  /// Call this in main() before runApp to prevent crashes on offline devices
  static void init() {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  static TextStyle _font({double? size, FontWeight? weight, Color? color, double? height, double? spacing}) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentOrange,
        brightness: Brightness.light,
        surface: Colors.white,
        surfaceContainerHighest: const Color(0xFFF7F9FC),
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      textTheme: _textTheme(Colors.black87),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        centerTitle: true,
        titleTextStyle: _font(size: 18, weight: FontWeight.w700, color: Colors.black),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        indicatorColor: primaryColor.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          _font(size: 11, weight: FontWeight.w600, color: primaryColor),
        ),
        iconTheme: WidgetStatePropertyAll(const IconThemeData(color: primaryColor)),
        height: 64,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE0E0E0), thickness: 0.5, space: 0),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F4F8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        side: BorderSide.none,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: primaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F4F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentPink,
        brightness: Brightness.dark,
        surface: const Color(0xFF141414), // Deep charcoal instead of generic grey
        surfaceContainerHighest: const Color(0xFF1E1E1E), // Slightly elevated grey
      ),
      scaffoldBackgroundColor: const Color(0xFF000000), // OLED Black
      textTheme: _textTheme(const Color(0xFFEDEDED)),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF000000).withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: primaryColor.withValues(alpha: 0.1),
        centerTitle: true,
        titleTextStyle: _font(size: 18, weight: FontWeight.w700, color: Colors.white),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: primaryColor.withValues(alpha: 0.5), // Electric glow
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF121212), // Very dark card
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF222222), width: 1), // Distinct edge
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        indicatorColor: primaryColor.withValues(alpha: 0.25),
        labelTextStyle: WidgetStatePropertyAll(
          _font(size: 11, weight: FontWeight.w600, color: Colors.white70),
        ),
        iconTheme: WidgetStatePropertyAll(const IconThemeData(color: Colors.white70)),
        height: 64,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF262626), thickness: 0.5, space: 0),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(24),
           side: BorderSide(color: primaryColor.withValues(alpha: 0.3)), // Colorful outline
        ),
        elevation: 0,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF262626))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF262626))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }

  static TextTheme _textTheme(Color color) {
    return TextTheme(
      displayLarge: _font(size: 34, weight: FontWeight.bold, color: color, spacing: 0.37),
      displayMedium: _font(size: 28, weight: FontWeight.bold, color: color, spacing: 0.36),
      headlineSmall: _font(size: 22, weight: FontWeight.bold, color: color, spacing: 0.35),
      titleLarge: _font(size: 20, weight: FontWeight.w600, color: color, spacing: 0.38),
      titleMedium: _font(size: 17, weight: FontWeight.w600, color: color, spacing: -0.41),
      bodyLarge: _font(size: 17, color: color, height: 1.5, spacing: -0.41),
      bodyMedium: _font(size: 15, color: color, height: 1.5, spacing: -0.24),
      labelLarge: _font(size: 15, weight: FontWeight.w600, color: color),
      labelSmall: _font(size: 11, color: color, spacing: 0.07),
    );
  }
}
