import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/audio_tts_service.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/exercise.dart';

class ScrambleDrill extends StatelessWidget {
  final ExerciseModel exercise;
  final List<int> selectedBankIndices;
  final Function(int bankIndex) onBankIndexSelected;
  final Function(int assembledPosition) onWordRemoved;

  const ScrambleDrill({
    super.key,
    required this.exercise,
    required this.selectedBankIndices,
    required this.onBankIndexSelected,
    required this.onWordRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final assembledWords = selectedBankIndices
        .where((idx) => idx >= 0 && idx < exercise.bankWords.length)
        .map((idx) => exercise.bankWords[idx])
        .toList();

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
            style: VocaTypography.bodyMedium.copyWith(
              color: const Color(0xFF4F46E5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Audio helper button
        if (exercise.targetSentenceWords.isNotEmpty)
          BouncyTap(
            onTap: () {
              VocaHaptics.light();
              AudioTtsService().speak(exercise.targetSentenceWords.join(' '));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded, color: Color(0xFF4F46E5), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Pista de pronunciación',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 20),

        // Active Sentence Slot Box
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 110),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: VocaColors.borderLight, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: assembledWords.isEmpty
              ? Center(
                  child: Text(
                    'Toca las palabras de abajo en el orden correcto',
                    style: VocaTypography.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                      color: VocaColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: List.generate(assembledWords.length, (pos) {
                    final word = assembledWords[pos];
                    return BouncyTap(
                      onTap: () {
                        VocaHaptics.selection();
                        onWordRemoved(pos);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF3730A3),
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
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOutBack,
                        );
                  }),
                ),
        ),

        const SizedBox(height: 26),

        // Word Bank Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BANCO DE PALABRAS',
              style: VocaTypography.caption.copyWith(
                letterSpacing: 1.2,
                color: VocaColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (assembledWords.isNotEmpty)
              Text(
                '${assembledWords.length}/${exercise.targetSentenceWords.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Word Bank Chips
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: List.generate(exercise.bankWords.length, (bankIndex) {
            final word = exercise.bankWords[bankIndex];
            final isUsed = selectedBankIndices.contains(bankIndex);

            return Opacity(
              opacity: isUsed ? 0.28 : 1.0,
              child: BouncyTap(
                onTap: isUsed
                    ? null
                    : () {
                        VocaHaptics.light();
                        onBankIndexSelected(bankIndex);
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUsed ? const Color(0xFFF1F5F9) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUsed ? const Color(0xFFE2E8F0) : VocaColors.borderSubtle,
                      width: 2,
                    ),
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
                      color: isUsed ? const Color(0xFF94A3B8) : VocaColors.darkSlate,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
