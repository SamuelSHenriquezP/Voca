import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';

class ExerciseHeader extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int hearts;
  final VoidCallback onClose;

  const ExerciseHeader({
    super.key,
    required this.progress,
    required this.hearts,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Close Button
            BouncyTap(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.close_rounded,
                  color: VocaColors.textMuted,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Dynamic Gradient Progress Bar
            Expanded(
              child: Stack(
                children: [
                  // Track
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: VocaColors.borderLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Fill Bar
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    widthFactor: progress.clamp(0.04, 1.0),
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            VocaColors.electricCyan,
                            VocaColors.emeraldGreen,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: VocaColors.emeraldGreenShadow,
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Live Hearts Counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: VocaColors.redTint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: VocaColors.rubyRed.withOpacity(0.25), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_rounded, color: VocaColors.rubyRed, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$hearts',
                    style: VocaTypography.buttonText.copyWith(
                      color: VocaColors.rubyRed,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

