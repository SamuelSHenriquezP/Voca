import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
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
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded, color: Color(0xFF0F172A), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Escuchar pronunciación',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 18),

        // Active Sentence Slot Box
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: assembledWords.isEmpty
              ? const Center(
                  child: Text(
                    'Toca las palabras inferiores en orden',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          word,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
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

        const SizedBox(height: 24),

        // Word Bank Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'BANCO DE PALABRAS',
              style: TextStyle(
                letterSpacing: 1.0,
                color: Color(0xFF64748B),
                fontSize: 11,
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
          spacing: 8,
          runSpacing: 10,
          children: List.generate(exercise.bankWords.length, (bankIndex) {
            final word = exercise.bankWords[bankIndex];
            final isUsed = selectedBankIndices.contains(bankIndex);

            return Opacity(
              opacity: isUsed ? 0.25 : 1.0,
              child: BouncyTap(
                onTap: isUsed
                    ? null
                    : () {
                        VocaHaptics.light();
                        onBankIndexSelected(bankIndex);
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                  decoration: BoxDecoration(
                    color: isUsed ? const Color(0xFFF1F5F9) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isUsed ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                      color: isUsed ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
