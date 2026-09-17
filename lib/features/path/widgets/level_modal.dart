import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
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
          const SizedBox(height: 16),

          // Tactical Cards Deck Preview
          Builder(
            builder: (context) {
              final storage = LocalStorageService();
              final shields = storage.getShields();
              final clues = storage.getClues();
              final skips = storage.getSkips();
              final doubleXp = storage.getDoubleXpCount();

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.style_rounded, size: 16, color: Color(0xFF6366F1)),
                    const SizedBox(width: 8),
                    const Text(
                      'Cartas listas:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    _buildMiniBadge('🛡️', shields, const Color(0xFF0D9488)),
                    const SizedBox(width: 6),
                    _buildMiniBadge('💡', clues, const Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    _buildMiniBadge('⏭️', skips, const Color(0xFF4F46E5)),
                    const SizedBox(width: 6),
                    _buildMiniBadge('⚡', doubleXp, const Color(0xFFEA580C)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

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

  Widget _buildMiniBadge(String emoji, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

