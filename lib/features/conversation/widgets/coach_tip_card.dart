import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';

class CoachTipCard extends StatefulWidget {
  final String grammarTip;
  final String pronunciationTip;
  final int fluencyScore;

  const CoachTipCard({
    super.key,
    this.grammarTip = 'Use "I am visiting for pleasure" rather than "I visit for pleasure".',
    this.pronunciationTip = 'Stress the first syllable in "PUR-pose".',
    this.fluencyScore = 92,
  });

  @override
  State<CoachTipCard> createState() => _CoachTipCardState();
}

class _CoachTipCardState extends State<CoachTipCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VocaColors.primaryPurple.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: VocaColors.primaryPurple.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header / Toggle
          BouncyTap(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: VocaColors.purpleTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: VocaColors.primaryPurple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Coach Insights',
                          style: VocaTypography.heading3.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Tap to view silent feedback & tips',
                          style: VocaTypography.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: VocaColors.greenTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.fluencyScore}% Fluency',
                      style: VocaTypography.caption.copyWith(
                        color: VocaColors.emeraldGreenShadow,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: VocaColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded) ...[
            const Divider(height: 1, color: VocaColors.borderLight),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grammar Pointer
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✍️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grammar Refinement',
                              style: VocaTypography.caption.copyWith(
                                color: VocaColors.darkSlate,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.grammarTip,
                              style: VocaTypography.bodySmall.copyWith(
                                color: VocaColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Pronunciation Pointer
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accent & Stress',
                              style: VocaTypography.caption.copyWith(
                                color: VocaColors.darkSlate,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.pronunciationTip,
                              style: VocaTypography.bodySmall.copyWith(
                                color: VocaColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

