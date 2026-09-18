import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/exercise.dart';

class ClozeFillDrill extends StatefulWidget {
  final ExerciseModel exercise;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;
  final Set<String>? disabledOptions;

  const ClozeFillDrill({
    super.key,
    required this.exercise,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.disabledOptions,
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
          // 1. Academic Category Tracker
          const Text(
            'COMPLETA LA ORACIÓN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),

          // 2. Prompt & Subtitle
          Text(
            ex.prompt,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          if (ex.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              ex.subtitle,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],

          // 3. Subtle Linguistic Rule Toggle
          if (ex.trickTip.isNotEmpty) ...[
            const SizedBox(height: 8),
            BouncyTap(
              onTap: () {
                setState(() => _showTrick = !_showTrick);
                VocaHaptics.selection();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showTrick ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showTrick ? 'Ocultar regla lingüística' : 'Ver regla lingüística',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_showTrick) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  ex.trickTip,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],

          const SizedBox(height: 20),

          // 4. Sentence Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 12,
              children: [
                if (ex.clozePrefix.isNotEmpty)
                  Text(
                    ex.clozePrefix,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      height: 1.4,
                    ),
                  ),

                // Inline Blank / Selected Slot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasSelection
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasSelection
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    hasSelection ? widget.selectedAnswer! : '        ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: hasSelection ? Colors.white : Colors.transparent,
                      height: 1.3,
                    ),
                  ),
                ),

                if (ex.clozeSuffix.isNotEmpty)
                  Text(
                    ex.clozeSuffix,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 5. Symmetric 2x2 Options Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ex.clozeOptions.map((opt) {
                  final isSelected = widget.selectedAnswer == opt;
                  final isDisabled = widget.disabledOptions?.contains(opt) ?? false;

                  if (isDisabled) {
                    return SizedBox(
                      width: itemWidth,
                      child: Opacity(
                        opacity: 0.25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            opt,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    width: itemWidth,
                    child: BouncyTap(
                      onTap: () {
                        VocaHaptics.selection();
                        widget.onAnswerSelected(opt);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.02),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
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
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

