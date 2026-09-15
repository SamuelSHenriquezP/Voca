import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';

class TopStickyBar extends StatelessWidget {
  final int streakDays;
  final int hearts;
  final int gems;
  final String languageCode;
  final VoidCallback? onFlagTap;
  final VoidCallback? onStreakTap;
  final VoidCallback? onHeartsTap;
  final VoidCallback? onGemsTap;

  const TopStickyBar({
    super.key,
    this.streakDays = 14,
    this.hearts = 5,
    this.gems = 480,
    this.languageCode = 'US',
    this.onFlagTap,
    this.onStreakTap,
    this.onHeartsTap,
    this.onGemsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: VocaColors.cardBackground,
        border: Border(
          bottom: BorderSide(color: VocaColors.borderLight, width: 2),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Language Flag Badge
            BouncyTap(
              onTap: onFlagTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: VocaColors.purpleTint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VocaColors.primaryPurple.withOpacity(0.2), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇺🇸', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 5),
                    Text(
                      'EN',
                      style: VocaTypography.buttonText.copyWith(
                        color: VocaColors.primaryPurple,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Streak Counter 🔥 with animated pulse
            BouncyTap(
              onTap: onStreakTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: VocaColors.orangeTint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VocaColors.sunOrange.withOpacity(0.2), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 18))
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.2, 1.2),
                          duration: const Duration(milliseconds: 900),
                        ),
                    const SizedBox(width: 5),
                    Text(
                      '$streakDays',
                      style: VocaTypography.buttonText.copyWith(
                        color: VocaColors.sunOrangeShadow,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Heart / Lives ❤️
            BouncyTap(
              onTap: onHeartsTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: VocaColors.redTint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VocaColors.rubyRed.withOpacity(0.2), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 17)),
                    const SizedBox(width: 5),
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
            ),

            // Gems / Coins 💎
            BouncyTap(
              onTap: onGemsTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: VocaColors.cyanTint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VocaColors.electricCyan.withOpacity(0.2), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 17)),
                    const SizedBox(width: 5),
                    Text(
                      '$gems',
                      style: VocaTypography.buttonText.copyWith(
                        color: VocaColors.electricCyanShadow,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

