import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/exercise.dart';

class ScrambleDrill extends StatelessWidget {
  final ExerciseModel exercise;
  final List<String> selectedWords;
  final Function(String word) onWordSelected;
  final Function(int index) onWordRemoved;

  const ScrambleDrill({
    super.key,
    required this.exercise,
    required this.selectedWords,
    required this.onWordSelected,
    required this.onWordRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt
        Text(
          exercise.prompt,
          style: VocaTypography.heading1.copyWith(fontSize: 22),
        ),
        if (exercise.subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            exercise.subtitle,
            style: VocaTypography.bodyMedium.copyWith(color: VocaColors.textMuted),
          ),
        ],
        const SizedBox(height: 24),

        // Active Sentence Slot Box
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: VocaColors.borderLight, width: 2),
          ),
          child: selectedWords.isEmpty
              ? Center(
                  child: Text(
                    'Tap words below to assemble the sentence',
                    style: VocaTypography.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                      color: VocaColors.textMuted,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: List.generate(selectedWords.length, (index) {
                    final word = selectedWords[index];
                    return BouncyTap(
                      onTap: () {
                        HapticUtils.selection();
                        onWordRemoved(index);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: VocaColors.primaryPurple,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: VocaColors.primaryPurpleShadow,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          word,
                          style: VocaTypography.buttonText.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ).animate().scale(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                        );
                  }),
                ),
        ),
        const SizedBox(height: 32),

        // Word Bank Title
        Text(
          'WORD BANK',
          style: VocaTypography.caption.copyWith(
            letterSpacing: 1.2,
            color: VocaColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),

        // Word Bank Chips
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: exercise.bankWords.map((word) {
            final isUsed = selectedWords.contains(word);
            return Opacity(
              opacity: isUsed ? 0.35 : 1.0,
              child: BouncyTap(
                onTap: isUsed
                    ? null
                    : () {
                        HapticUtils.light();
                        onWordSelected(word);
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VocaColors.borderSubtle, width: 2),
                    boxShadow: isUsed
                        ? null
                        : const [
                            BoxShadow(
                              color: VocaColors.borderSubtle,
                              offset: Offset(0, 3.5),
                              blurRadius: 0,
                            ),
                          ],
                  ),
                  child: Text(
                    word,
                    style: VocaTypography.buttonText.copyWith(
                      color: VocaColors.darkSlate,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
