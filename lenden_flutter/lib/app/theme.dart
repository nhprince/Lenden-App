import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lenden App Theme — mirrors the web app's Tailwind design system.
/// Uses Plus Jakarta Sans font, glassmorphism, gradient accents.
class AppTheme {
  AppTheme._();

  // ─── Brand Colors ────────────────────────────────────────
  static const Color primary50 = Color(0xFFEFF6FF);
  static const Color primary100 = Color(0xFFDBEAFE);
  static const Color primary200 = Color(0xFFBFDBFE);
  static const Color primary400 = Color(0xFF60A5FA);
  static const Color primary500 = Color(0xFF3B82F6);
  static const Color primary600 = Color(0xFF2563EB);
  static const Color primary700 = Color(0xFF1D4ED8);

  static const Color secondary400 = Color(0xFF34D399);
  static const Color secondary500 = Color(0xFF10B981);
  static const Color secondary600 = Color(0xFF059669);

  static const Color danger400 = Color(0xFFF87171);
  static const Color danger500 = Color(0xFFEF4444);
  static const Color danger600 = Color(0xFFDC2626);

  static const Color warning400 = Color(0xFFFBBF24);
  static const Color warning500 = Color(0xFFF59E0B);

  // ─── Background Colors ───────────────────────────────────
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF030712);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF1F2937);

  // ─── Text Colors ─────────────────────────────────────────
  static const Color textMain = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // ─── Gradients (matching CSS variables) ──────────────────
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
  );

  static const LinearGradient gradientSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );

  static const LinearGradient gradientDanger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
  );

  static const LinearGradient gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  );

  // ─── Border Radius ───────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;

  // ─── Shadows ─────────────────────────────────────────────
  static List<BoxShadow> get shadowSoft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowHard => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> shadowPrimary = [
        BoxShadow(
          color: primary600.withValues(alpha: 0.30),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // ─── Light Theme ─────────────────────────────────────────
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: primary600,
        secondary: secondary500,
        error: danger500,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: textMain,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary600,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary600.withValues(alpha: 0.30),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textMain,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: Colors.grey.shade300, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger500, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary600,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primary600,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: primary500,
        secondary: secondary500,
        error: danger500,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary600,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary600.withValues(alpha: 0.30),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.grey.shade700, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.grey.shade700, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary500, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primary500,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
