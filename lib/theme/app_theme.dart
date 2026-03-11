import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightBlue,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.darkBlue,
        surfaceContainerHighest: AppColors.grey98,
        outline: AppColors.lightGray,
        onSurfaceVariant: AppColors.gray,
      ),
      scaffoldBackgroundColor: AppColors.grey98,
      textTheme: _textTheme,
      inputDecorationTheme: _inputDecorationTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      headlineLarge: GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 40 / 36,
        letterSpacing: -0.9,
        color: AppColors.darkBlue,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.5,
        color: AppColors.darkBlue,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 28 / 18,
        color: AppColors.darkBlue,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.gray,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.gray,
      ),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 28 / 16,
        color: AppColors.white,
      ),
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey98,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.lightGray, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.lightBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.gray,
      ),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
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
}
