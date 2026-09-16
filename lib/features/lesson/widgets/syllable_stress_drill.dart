import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/exercise.dart';

class SyllableStressDrill extends StatefulWidget {
  final ExerciseModel exercise;
  final int? selectedIndex;
  final ValueChanged<int> onIndexSelected;

  const SyllableStressDrill({
    super.key,
    required this.exercise,
    required this.selectedIndex,
    required this.onIndexSelected,
  });

  @override
  State<SyllableStressDrill> createState() => _SyllableStressDrillState();
}

class _SyllableStressDrillState extends State<SyllableStressDrill> {
  bool _showTrick = false;

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Prompt & Subtitle
          Text(
            ex.prompt,
            style: VocaTypography.heading2.copyWith(fontSize: 20),
          ),
          if (ex.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              ex.subtitle,
              style: VocaTypography.bodyMedium.copyWith(color: VocaColors.textMuted),
            ),
          ],

          const SizedBox(height: 16),

          // 2. Trick Toggle
          if (ex.trickTip.isNotEmpty)
            BouncyTap(
              onTap: () {
                setState(() => _showTrick = !_showTrick);
                VocaHaptics.selection();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _showTrick ? 'HIDE TRICK' : 'RHYTHM TRICK',
                      style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_showTrick && ex.trickTip.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                ex.trickTip,
                style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 3. IPA Pronunciation Header
          if (ex.ipaPhonetic.isNotEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ex.ipaPhonetic,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

          const Spacer(),

          // 4. Syllable Blocks Row
          Center(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(ex.syllables.length, (index) {
                final isSelected = widget.selectedIndex == index;
                final syllable = ex.syllables[index];

                return BouncyTap(
                  onTap: () {
                    VocaHaptics.selection();
                    widget.onIndexSelected(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFFCBD5E1),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF4F46E5).withOpacity(0.35)
                              : Colors.black.withOpacity(0.04),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Stress Pitch Dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          syllable.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: isSelected ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const Spacer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

