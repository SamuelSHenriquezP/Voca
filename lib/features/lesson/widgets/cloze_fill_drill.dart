import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/exercise.dart';

class ClozeFillDrill extends StatefulWidget {
  final ExerciseModel exercise;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;

  const ClozeFillDrill({
    super.key,
    required this.exercise,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  State<ClozeFillDrill> createState() => _ClozeFillDrillState();
}

class _ClozeFillDrillState extends State<ClozeFillDrill> {
  bool _showTrick = false;

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final hasSelection = widget.selectedAnswer != null;

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

          // 2. Trick Toggle Pill (Duolingo mnemonic hack)
          if (ex.trickTip.isNotEmpty)
            BouncyTap(
              onTap: () {
                setState(() => _showTrick = !_showTrick);
                VocaHaptics.selection();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tips_and_updates_rounded,
                        color: Color(0xFF059669), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _showTrick ? 'HIDE TRICK' : 'NATIVE TRICK',
                      style: const TextStyle(
                        color: Color(0xFF059669),
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
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Text(
                ex.trickTip,
                style: const TextStyle(
                  color: Color(0xFF065F46),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 3. Sentence Cloze Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 10,
              children: [
                if (ex.clozePrefix.isNotEmpty)
                  Text(
                    ex.clozePrefix,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                // Blank Slot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: hasSelection
                        ? const Color(0xFF4F46E5).withOpacity(0.1)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasSelection
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    hasSelection ? widget.selectedAnswer! : '      ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: hasSelection ? const Color(0xFF4F46E5) : Colors.transparent,
                    ),
                  ),
                ),

                if (ex.clozeSuffix.isNotEmpty)
                  Text(
                    ex.clozeSuffix,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
              ],
            ),
          ),

          const Spacer(),

          // 4. Options Grid
          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ex.clozeOptions.map((opt) {
                final isSelected = widget.selectedAnswer == opt;

                return BouncyTap(
                  onTap: () {
                    VocaHaptics.selection();
                    widget.onAnswerSelected(opt);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF4F46E5).withOpacity(0.3)
                              : Colors.black.withOpacity(0.04),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

