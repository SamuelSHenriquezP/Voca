import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/notion_avatar.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Language Badge (Vector Icon)
            BouncyTap(
              onTap: onFlagTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language_rounded, size: 16, color: VocaColors.primaryPurple),
                    const SizedBox(width: 6),
                    Text(
                      languageCode,
                      style: VocaTypography.caption.copyWith(
                        color: VocaColors.darkSlate,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Streak Counter
            BouncyTap(
              onTap: onStreakTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: Color(0xFFD97706),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.15, 1.15),
                          duration: const Duration(milliseconds: 900),
                        ),
                    const SizedBox(width: 6),
                    Text(
                      '$streakDays',
                      style: VocaTypography.caption.copyWith(
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hearts Counter
            BouncyTap(
              onTap: onHeartsTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 15,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$hearts',
                      style: VocaTypography.caption.copyWith(
                        color: const Color(0xFF991B1B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Gems / Tokens
            BouncyTap(
              onTap: onGemsTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.diamond_outlined,
                      size: 15,
                      color: Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$gems',
                      style: VocaTypography.caption.copyWith(
                        color: const Color(0xFF075985),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // User Notion Avatar & Session Button
            if (onProfileTap != null)
              BouncyTap(
                onTap: onProfileTap,
                child: Builder(
                  builder: (context) {
                    final storage = LocalStorageService();
                    return Tooltip(
                      message: 'Tu Perfil y Avatar Notion',
                      child: NotionAvatar(
                        head: storage.getNotionHead(),
                        hair: storage.getNotionHair(),
                        eyes: storage.getNotionEyes(),
                        mouth: storage.getNotionMouth(),
                        outfit: storage.getNotionOutfit(),
                        backdrop: storage.getNotionBackdrop(),
                        size: 34,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
