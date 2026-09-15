import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'voca_colors.dart';

/// Playful, rounded, bold typography for VOCA
class VocaTypography {
  VocaTypography._();

  static TextStyle get display => GoogleFonts.fredoka(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: VocaColors.darkSlate,
        letterSpacing: -0.5,
      );

  static TextStyle get heading1 => GoogleFonts.fredoka(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: VocaColors.darkSlate,
        letterSpacing: -0.3,
      );

  static TextStyle get heading2 => GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: VocaColors.darkSlate,
      );

  static TextStyle get heading3 => GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: VocaColors.darkSlate,
      );

  static TextStyle get buttonText => GoogleFonts.fredoka(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: VocaColors.darkSlate,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: VocaColors.darkSlate,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: VocaColors.textMuted,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: VocaColors.textMuted,
      );

  static TextStyle get phonetic => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        color: VocaColors.primaryPurple,
      );
}

