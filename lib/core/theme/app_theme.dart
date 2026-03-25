import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.xColor,
        tertiary: AppColors.oColor,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        headlineMedium: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.surfaceContainer.withOpacity(.92),
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.6,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      dividerColor: AppColors.divider,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLowest,
        hintStyle: GoogleFonts.spaceGrotesk(
          color: AppColors.textMuted,
          letterSpacing: 1,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: GoogleFonts.spaceGrotesk(
          color: AppColors.textMuted,
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.ghostBorder),
          backgroundColor: AppColors.surfaceHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
