import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senior_ease/services/app_settings_controller.dart';

class AppColors {
  AppColors._();

  static const Color lightBlue = Color(0xFF117CEE);
  static const Color darkBlue = Color(0xFF172636);
  static const Color gray = Color(0xFF576575);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFC6D1DD);
  static const Color grey98 = Color(0xFFF8FAFB);
  static const Color codGray = Color(0xFF121212);
  static const Color jungleGreen = Color(0xFF2BAB6F);
  static const Color linkWater = Color(0xFFE7EFF9);
}

class AppTheme {
  AppTheme._();

  /// Tema completo conforme contraste (tamanho de fonte via [MediaQuery.textScaler]).
  static ThemeData themeForSettings(AppSettingsController settings) {
    final hc = settings.highContrast;
    final cs = hc ? _highContrastColorScheme : _normalColorScheme;
    final textTheme = _textTheme(cs);
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: hc ? AppColors.white : AppColors.grey98,
      textTheme: textTheme,
      inputDecorationTheme: _inputDecorationTheme(cs, hc),
      elevatedButtonTheme: _elevatedButtonTheme,
    );
  }

  static ColorScheme get _normalColorScheme {
    return ColorScheme.light(
      primary: AppColors.lightBlue,
      onPrimary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.darkBlue,
      surfaceContainerHighest: AppColors.grey98,
      outline: AppColors.lightGray,
      onSurfaceVariant: AppColors.gray,
    );
  }

  /// Texto preto e contornos fortes para leitura com máximo contraste.
  static ColorScheme get _highContrastColorScheme {
    return const ColorScheme.light(
      primary: Color(0xFF0D5AA7),
      onPrimary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
      surfaceContainerHighest: Color(0xFFF0F0F0),
      outline: Color(0xFF000000),
      onSurfaceVariant: Color(0xFF1A1A1A),
      error: Color(0xFFB00020),
      onError: Color(0xFFFFFFFF),
    );
  }

  static TextTheme _textTheme(ColorScheme cs) {
    return TextTheme(
      headlineLarge: GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 40 / 36,
        letterSpacing: -0.9,
        color: cs.onSurface,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.5,
        color: cs.onSurface,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 28 / 18,
        color: cs.onSurface,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: cs.onSurfaceVariant,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: cs.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 28 / 16,
        color: AppColors.white,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(
    ColorScheme cs,
    bool highContrast,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: highContrast ? AppColors.white : AppColors.grey98,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: cs.outline, width: highContrast ? 2 : 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(
          color: AppColors.lightBlue,
          width: highContrast ? 3 : 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightBlue,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 28 / 16,
          ),
        ),
      );
}
