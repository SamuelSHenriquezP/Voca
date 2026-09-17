import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'voca_colors.dart';
import 'voca_typography.dart';

class VocaTheme {
  VocaTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: VocaColors.backgroundNeutral,
      primaryColor: VocaColors.primaryPurple,
      colorScheme: const ColorScheme.light(
        primary: VocaColors.primaryPurple,
        secondary: VocaColors.accentPink,
        tertiary: VocaColors.electricCyan,
        surface: VocaColors.cardBackground,
        error: VocaColors.rubyRed,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: VocaTypography.display,
        displayMedium: VocaTypography.displayMedium,
        headlineLarge: VocaTypography.heading1,
        headlineMedium: VocaTypography.heading2,
        headlineSmall: VocaTypography.heading3,
        bodyLarge: VocaTypography.bodyLarge,
        bodyMedium: VocaTypography.bodyMedium,
        bodySmall: VocaTypography.bodySmall,
        labelLarge: VocaTypography.buttonText,
        labelSmall: VocaTypography.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: VocaColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: VocaColors.borderLight, width: 2),
        ),
      ),
    );
  }
}
