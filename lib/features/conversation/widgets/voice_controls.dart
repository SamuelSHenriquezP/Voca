import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';

class VoiceControls extends StatelessWidget {
  final bool isSpeaking;
  final bool isRecording;
  final VoidCallback onToggleRecording;
  final VoidCallback onHint;
  final VoidCallback onSurrender;

  const VoiceControls({
    super.key,
    required this.isSpeaking,
    required this.isRecording,
    required this.onToggleRecording,
    required this.onHint,
    required this.onSurrender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: VocaColors.borderLight, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Hint Button
            BouncyTap(
              onTap: onHint,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: VocaColors.goldTint,
                      shape: BoxShape.circle,
                      border: Border.all(color: VocaColors.goldXp, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFFB07200),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hint',
                    style: VocaTypography.caption.copyWith(
                      color: VocaColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Main Glowing Pushable Microphone Button
            GestureDetector(
              onTap: () {
                HapticUtils.medium();
                onToggleRecording();
              },
              child: SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Aura
                    if (isRecording)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: VocaColors.accentPink.withOpacity(0.25),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.3, 1.3),
                            duration: const Duration(milliseconds: 650),
                          ),

                    // Shadow Base
                    Positioned(
                      top: 5,
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRecording
                              ? VocaColors.accentPinkShadow
                              : VocaColors.primaryPurpleShadow,
                        ),
                      ),
                    ),

                    // Surface
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRecording ? VocaColors.accentPink : VocaColors.primaryPurple,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: (isRecording ? VocaColors.accentPink : VocaColors.primaryPurple)
                                .withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Surrender Button
            BouncyTap(
              onTap: onSurrender,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: VocaColors.redTint,
                      shape: BoxShape.circle,
                      border: Border.all(color: VocaColors.rubyRed.withOpacity(0.5), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.flag_outlined,
                      color: VocaColors.rubyRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Surrender',
                    style: VocaTypography.caption.copyWith(
                      color: VocaColors.textMuted,
                      fontWeight: FontWeight.w700,
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

