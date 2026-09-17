import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/voca_button.dart';
import '../models/level_node.dart';

class LevelModal extends StatelessWidget {
  final LevelNodeModel node;
  final VoidCallback onStart;

  const LevelModal({
    super.key,
    required this.node,
    required this.onStart,
  });

  static void show(BuildContext context, LevelNodeModel node, VoidCallback onStart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LevelModal(
        node: node,
        onStart: () {
          Navigator.of(context).pop();
          onStart();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: VocaColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: VocaColors.borderSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: VocaColors.cyanTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'UNIDAD ${node.unitNumber} • NIVEL ${node.levelNumber}',
              style: VocaTypography.caption.copyWith(
                color: VocaColors.electricCyanShadow,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            node.title,
            style: VocaTypography.heading1.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            node.subtitle,
            style: VocaTypography.bodyMedium.copyWith(color: VocaColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Lesson Objectives
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VocaColors.backgroundNeutral,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: VocaColors.borderLight, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_rounded, color: VocaColors.primaryPurple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Objetivos de la Lección',
                      style: VocaTypography.heading3.copyWith(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...node.objectives.map((obj) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: VocaColors.emeraldGreen, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              obj,
                              style: VocaTypography.bodySmall.copyWith(
                                color: VocaColors.darkSlate,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Large Start Button
          VocaButton(
            text: 'EMPEZAR LECCIÓN (+${node.xpReward} XP)',
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
            variant: VocaButtonVariant.success,
            isFullWidth: true,
            height: 56,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

