import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/voca_avatar.dart';
import '../../../core/widgets/bouncy_tap.dart';

class HeroProfileCard extends StatelessWidget {
  final String username;
  final String handle;
  final String levelTitle;
  final int levelNumber;
  final VoidCallback? onEditAvatar;

  const HeroProfileCard({
    super.key,
    this.username = 'Alex Rivera',
    this.handle = '@alex_rivera',
    this.levelTitle = 'B1 • Street Conversationalist',
    this.levelNumber = 14,
    this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: VocaColors.borderLight, width: 2),
        boxShadow: const [
          BoxShadow(
            color: VocaColors.borderSubtle,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with customizable glowing frame
          BouncyTap(
            onTap: onEditAvatar,
            child: Stack(
              children: [
                Builder(
                  builder: (context) {
                    final storage = LocalStorageService();
                    return Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0F172A), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: VocaAvatar(
                          head: storage.getVocaHead(),
                          hair: storage.getVocaHair(),
                          eyes: storage.getVocaEyes(),
                          mouth: storage.getVocaMouth(),
                          outfit: storage.getVocaOutfit(),
                          backdrop: storage.getVocaBackdrop(),
                          size: 72,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: VocaColors.goldXp,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 13,
                      color: Color(0xFF6B4500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),

          // User Info & Badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: VocaTypography.heading2.copyWith(fontSize: 20),
                ),
                Text(
                  handle,
                  style: VocaTypography.bodySmall.copyWith(color: VocaColors.textMuted),
                ),
                const SizedBox(height: 8),

                // Level Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: VocaColors.purpleTint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: VocaColors.primaryPurple.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: VocaColors.primaryPurple,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        levelTitle,
                        style: VocaTypography.caption.copyWith(
                          color: VocaColors.primaryPurple,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
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
    );
  }
}

