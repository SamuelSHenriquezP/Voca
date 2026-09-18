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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 18),

          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'UNIDAD ${node.unitNumber} • MÓDULO ${node.levelNumber} • ${node.focusLabel}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            node.title,
            style: VocaTypography.heading1.copyWith(
              fontSize: 20,
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            node.subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Lesson Objectives
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.format_list_bulleted_rounded, color: Color(0xFF0F172A), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Objetivos de Aprendizaje',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...node.objectives.map((obj) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_rounded, color: Color(0xFF0F172A), size: 15),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              obj,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF334155),
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
          const SizedBox(height: 14),

          // Tactical Cards Deck Preview (Monochrome)
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
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 15, color: Color(0xFF0F172A)),
                    const SizedBox(width: 8),
                    const Text(
                      'Inventario:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    _buildMiniBadge('🛡️', shields),
                    const SizedBox(width: 6),
                    _buildMiniBadge('💡', clues),
                    const SizedBox(width: 6),
                    _buildMiniBadge('⏭️', skips),
                    const SizedBox(width: 6),
                    _buildMiniBadge('⚡', doubleXp),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Large Start Button (Monochrome Carbon)
          VocaButton(
            text: 'INICIAR LECCIÓN (+${node.xpReward} XP)',
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            variant: VocaButtonVariant.primary,
            isFullWidth: true,
            height: 52,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String emoji, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
