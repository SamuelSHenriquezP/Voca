import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';

class BadgeItem {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final String? unlockDate;
  final Color glowColor;

  const BadgeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.isUnlocked,
    this.unlockDate,
    this.glowColor = VocaColors.goldXp,
  });
}

class BadgeGallery extends StatelessWidget {
  final List<BadgeItem> badges;

  const BadgeGallery({
    super.key,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACHIEVEMENTS',
                style: VocaTypography.heading3.copyWith(
                  fontSize: 15,
                  letterSpacing: 1.2,
                  color: VocaColors.darkSlate,
                ),
              ),
              Text(
                '${badges.where((b) => b.isUnlocked).length}/${badges.length} Unlocked',
                style: VocaTypography.caption.copyWith(
                  color: VocaColors.primaryPurple,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 154,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: badges.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final badge = badges[index];

              return BouncyTap(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${badge.name}: ${badge.description}'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 114,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: badge.isUnlocked ? badge.glowColor.withOpacity(0.5) : VocaColors.borderLight,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: badge.isUnlocked
                            ? badge.glowColor.withOpacity(0.25)
                            : VocaColors.borderSubtle.withOpacity(0.4),
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 3D Medal Emoji Container
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badge.isUnlocked ? badge.glowColor.withOpacity(0.15) : VocaColors.borderLight,
                        ),
                        child: Center(
                          child: ColorFiltered(
                            colorFilter: badge.isUnlocked
                                ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                            child: Text(
                              badge.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Name
                      Text(
                        badge.name,
                        style: VocaTypography.heading3.copyWith(
                          fontSize: 12,
                          color: badge.isUnlocked ? VocaColors.darkSlate : VocaColors.lockedGray,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),

                      // Date or Locked
                      Text(
                        badge.isUnlocked ? (badge.unlockDate ?? 'Unlocked') : 'Locked',
                        style: VocaTypography.caption.copyWith(
                          fontSize: 10,
                          color: badge.isUnlocked ? VocaColors.primaryPurple : VocaColors.lockedGray,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
