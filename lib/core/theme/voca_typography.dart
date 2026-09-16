import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'voca_colors.dart';

/// Adapted, high-end typography pairings for VOCA:
/// - Space Grotesk: Expressive display titles, biomes, bosses, cards.
/// - Plus Jakarta Sans: Crystal-clear UI, buttons, prompts, options.
/// - JetBrains Mono: Authentic phonetic notation (IPA), acoustic tokens.
/// - Outfit: Spoken conversational dialogue and narrative lore.
class VocaTypography {
  VocaTypography._();

  static TextStyle get display => GoogleFonts.spaceGrotesk(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: VocaColors.darkSlate,
        letterSpacing: -0.8,
      );

  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: VocaColors.darkSlate,
        letterSpacing: -0.5,
      );

  static TextStyle get heading1 => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: VocaColors.darkSlate,
        letterSpacing: -0.5,
      );

  static TextStyle get heading2 => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: VocaColors.darkSlate,
        letterSpacing: -0.3,
      );

  static TextStyle get heading3 => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: VocaColors.darkSlate,
      );

  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: VocaColors.darkSlate,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: VocaColors.darkSlate,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: VocaColors.textMuted,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: VocaColors.textMuted,
        letterSpacing: 0.5,
      );

  static TextStyle get phonetic => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: VocaColors.primaryPurple,
        letterSpacing: 0.5,
      );

  static TextStyle get dialogue => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: VocaColors.darkSlate,
        height: 1.4,
      );
}
