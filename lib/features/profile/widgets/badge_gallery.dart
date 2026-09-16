import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';

class BadgeItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final String? unlockDate;
  final Color accentColor;

  const BadgeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockDate,
    this.accentColor = const Color(0xFF4F46E5),
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
                style: VocaTypography.caption.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                  color: VocaColors.darkSlate,
                ),
              ),
              Text(
                '${badges.where((b) => b.isUnlocked).length} / ${badges.length}',
                style: VocaTypography.caption.copyWith(
                  color: const Color(0xFF4F46E5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: badges.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final badge = badges[index];

              return BouncyTap(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${badge.name}: ${badge.description}'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 110,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: badge.isUnlocked ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(badge.isUnlocked ? 0.03 : 0.0),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minimalist Badge Emblem Icon (No Emojis)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badge.isUnlocked ? badge.accentColor.withOpacity(0.08) : const Color(0xFFF4F4F5),
                        ),
                        child: Center(
                          child: Icon(
                            badge.icon,
                            size: 20,
                            color: badge.isUnlocked ? badge.accentColor : const Color(0xFFA1A1AA),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        badge.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: badge.isUnlocked ? VocaColors.darkSlate : const Color(0xFFA1A1AA),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),

                      Text(
                        badge.isUnlocked ? (badge.unlockDate ?? 'Unlocked') : 'Locked',
                        style: TextStyle(
                          fontSize: 10,
                          color: badge.isUnlocked ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w500,
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
