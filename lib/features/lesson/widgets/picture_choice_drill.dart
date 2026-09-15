import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/exercise.dart';

class PictureChoiceDrill extends StatelessWidget {
  final ExerciseModel exercise;
  final String? selectedOptionId;
  final Function(PictureChoiceOption option) onOptionSelected;

  const PictureChoiceDrill({
    super.key,
    required this.exercise,
    required this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "NEW WORD" Duolingo-style pill (Image 3)
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Color(0xFFA855F7), size: 16),
                  SizedBox(width: 4),
                  Text(
                    'NEW WORD',
                    style: TextStyle(
                      color: Color(0xFFA855F7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Prompt
        Text(
          'Select the correct image',
          style: VocaTypography.heading1.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3C3C3C),
          ),
        ),
        const SizedBox(height: 8),

        // Audio Prompt Row (Image 3: speaker + word with underline)
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF1CB0F6), // Duolingo blue speaker
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.only(bottom: 2),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF1CB0F6),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: Text(
                'the check',
                style: VocaTypography.heading2.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF1CB0F6),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 2x2 Picture Choice Grid with 3D tactile pushable cards (Image 3)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.88,
          ),
          itemCount: exercise.pictureOptions.length,
          itemBuilder: (context, index) {
            final option = exercise.pictureOptions[index];
            final isSelected = selectedOptionId == option.id;

            final cardBorderColor = isSelected ? const Color(0xFF1CB0F6) : const Color(0xFFE5E5E5);
            final cardShadowColor = isSelected ? const Color(0xFF1899D6) : const Color(0xFFDCDCDC);
            final cardBgColor = isSelected ? const Color(0xFFDDF4FF) : Colors.white;

            return BouncyTap(
              onTap: () {
                HapticUtils.selection();
                onOptionSelected(option);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cardBorderColor,
                    width: isSelected ? 2.5 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cardShadowColor,
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Illustration / Character / Number
                    Expanded(
                      child: Center(
                        child: Text(
                          option.emoji,
                          style: const TextStyle(fontSize: 54),
                        ),
                      ),
                    ),

                    // Label & Audio phonetic
                    Column(
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? const Color(0xFF1899D6) : const Color(0xFF4B4B4B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.audioPhonetic,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 60 * index));
          },
        ),
      ],
    );
  }
}
