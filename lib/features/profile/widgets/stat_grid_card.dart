import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';

class StatGridCard extends StatelessWidget {
  final String title;
  final String value;
  final String footer;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? visualElement;

  const StatGridCard({
    super.key,
    required this.title,
    required this.value,
    required this.footer,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.visualElement,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = backgroundColor == const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.08 : 0.02),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon & Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          // Big Stat Value
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : VocaColors.darkSlate,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          // Optional Visual Detail
          ?visualElement,

          // Footer
          Text(
            footer,
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Builder 1: Streak Card (Obsidian Minimalist)
  static Widget buildStreakCard({int streak = 14}) {
    return StatGridCard(
      title: 'Streak',
      value: '$streak Days',
      footer: 'Active practice daily',
      icon: Icons.local_fire_department_rounded,
      iconColor: const Color(0xFFF59E0B),
      backgroundColor: const Color(0xFF0F172A),
      borderColor: const Color(0xFF1E293B),
      visualElement: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
          final isDone = day != 'S';
          return Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFF59E0B) : const Color(0xFF334155),
              shape: BoxShape.circle,
            ),
            child: isDone
                ? const Icon(Icons.check_rounded, color: Color(0xFF0F172A), size: 10)
                : null,
          );
        }).toList(),
      ),
    );
  }

  // Builder 2: Spoken Minutes Card (Crisp White + Waveform Mini Chart)
  static Widget buildSpokenAudioCard({int minutes = 342}) {
    final heights = [10.0, 18.0, 14.0, 24.0, 20.0, 26.0, 22.0];
    return StatGridCard(
      title: 'Spoken',
      value: '${minutes}m',
      footer: '+28m logged today',
      icon: Icons.graphic_eq_rounded,
      iconColor: const Color(0xFF4F46E5),
      visualElement: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: heights.map((h) {
          return Container(
            width: 10,
            height: h,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.75),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Builder 3: Vocabulary Card
  static Widget buildVocabularyCard({int words = 850}) {
    return const StatGridCard(
      title: 'Words',
      value: '850',
      footer: '12 words due for review',
      icon: Icons.menu_book_rounded,
      iconColor: Color(0xFF059669),
      visualElement: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Spaced Repetition Active',
          style: TextStyle(
            color: Color(0xFF059669),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Builder 4: Pronunciation Accuracy Card
  static Widget buildAccuracyCard({int score = 88}) {
    return StatGridCard(
      title: 'Accuracy',
      value: '$score%',
      footer: 'Native speaker benchmark',
      icon: Icons.track_changes_rounded,
      iconColor: const Color(0xFF0284C7),
      visualElement: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: score / 100,
          backgroundColor: const Color(0xFFE2E8F0),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
          minHeight: 6,
        ),
      ),
    );
  }
}
