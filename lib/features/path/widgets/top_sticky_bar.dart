import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/voca_avatar.dart';

/// Ultra-minimalist top bar for VOCA.
/// Pure monochrome, quiet slate tones, zero exotic candy gamification colors.
class TopStickyBar extends StatelessWidget {
  final int streakDays;
  final int hearts;
  final int gems;
  final String languageCode;
  final VoidCallback? onFlagTap;
  final VoidCallback? onStreakTap;
  final VoidCallback? onHeartsTap;
  final VoidCallback? onGemsTap;
  final VoidCallback? onProfileTap;

  const TopStickyBar({
    super.key,
    this.streakDays = 0,
    this.hearts = 5,
    this.gems = 0,
    this.languageCode = 'EN',
    this.onFlagTap,
    this.onStreakTap,
    this.onHeartsTap,
    this.onGemsTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final storage = LocalStorageService();
    final userName = storage.getUserName();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Left: VOCA Avatar & User Identity
            if (onProfileTap != null)
              Expanded(
                child: BouncyTap(
                  onTap: onProfileTap,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                        ),
                        child: VocaAvatar(
                          head: storage.getVocaHead(),
                          hair: storage.getVocaHair(),
                          eyes: storage.getVocaEyes(),
                          mouth: storage.getVocaMouth(),
                          outfit: storage.getVocaOutfit(),
                          backdrop: storage.getVocaBackdrop(),
                          size: 32,
                          isAnimated: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const Text(
                              'INGLÉS CEFR',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Spacer(),

            const SizedBox(width: 8),

            // Right: Clean Unified Stats Pill (Monochrome / Paper)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Streak
                  BouncyTap(
                    onTap: onStreakTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFF0F172A)),
                        const SizedBox(width: 4),
                        Text(
                          '$streakDays',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 12, color: const Color(0xFFCBD5E1)),
                  const SizedBox(width: 8),

                  // Hearts
                  BouncyTap(
                    onTap: onHeartsTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded, size: 13, color: Color(0xFF0F172A)),
                        const SizedBox(width: 4),
                        Text(
                          '$hearts',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 12, color: const Color(0xFFCBD5E1)),
                  const SizedBox(width: 8),

                  // XP
                  BouncyTap(
                    onTap: onGemsTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF0F172A)),
                        const SizedBox(width: 3),
                        Text(
                          '$gems XP',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
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
