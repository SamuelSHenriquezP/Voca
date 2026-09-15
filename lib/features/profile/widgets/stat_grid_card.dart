import 'package:flutter/material.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';

class StatGridCard extends StatelessWidget {
  final String title;
  final String value;
  final String footer;
  final Color backgroundColor;
  final Widget? customBadge;
  final VoidCallback? onMenuTap;

  const StatGridCard({
    super.key,
    required this.title,
    required this.value,
    required this.footer,
    required this.backgroundColor,
    this.customBadge,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.35),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Row: SpaceApp Yellow Folder Badge & 3-Dots Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Yellow Rounded Folder Badge
              customBadge ??
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.folder_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

              // 3-Dots Vertical Menu
              BouncyTap(
                onTap: onMenuTap,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white.withOpacity(0.85),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title & Large Stat Value (SpaceApp Style)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: VocaTypography.heading2.copyWith(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: VocaTypography.heading1.copyWith(
                  color: Colors.white.withOpacity(0.92),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Footer Text
          Text(
            footer,
            style: VocaTypography.caption.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Builder 1: SpaceApp Photos Card (Deep Purple #5C33CF) -> Streak
  static Widget buildStreakCard({int streak = 14}) {
    return StatGridCard(
      title: 'Active Streak',
      value: '$streak Days',
      footer: 'Last session 1 hour ago',
      backgroundColor: const Color(0xFF5C33CF), // Authentic SpaceApp Purple
      customBadge: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFFB800),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('🔥', style: TextStyle(fontSize: 22)),
        ),
      ),
    );
  }

  // Builder 2: SpaceApp Songs Card (Sunset Orange #FF7643) -> Spoken Time
  static Widget buildSpokenAudioCard({int minutes = 342}) {
    return StatGridCard(
      title: 'Spoken Audio',
      value: '${minutes}m',
      footer: 'Last spoken 3 hours ago',
      backgroundColor: const Color(0xFFFF7643), // Authentic SpaceApp Orange
      customBadge: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFFB800),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('🎙️', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  // Builder 3: SpaceApp Videos Card (Neon Cyan #00C2FF) -> Mastered Vocabulary
  static Widget buildVocabularyCard({int words = 850}) {
    return StatGridCard(
      title: 'Vocabulary',
      value: '$words',
      footer: 'Last update 2 days ago',
      backgroundColor: const Color(0xFF00C2FF), // Authentic SpaceApp Cyan
      customBadge: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFFB800),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('📚', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  // Builder 4: SpaceApp Documents Card (Hot Magenta/Pink #FF2D78) -> Accuracy
  static Widget buildAccuracyCard({int score = 88}) {
    return StatGridCard(
      title: 'Pronunciation',
      value: '$score% Match',
      footer: 'Last test 1 day ago',
      backgroundColor: const Color(0xFFFF2D78), // Authentic SpaceApp Magenta
      customBadge: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFFB800),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('🎯', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
