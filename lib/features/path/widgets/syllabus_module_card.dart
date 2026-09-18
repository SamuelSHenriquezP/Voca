import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/notion_avatar.dart';
import '../models/level_node.dart';

/// Minimalist, editorial syllabus module card for VOCA.
/// Replaces the winding Duolingo-style snake with a structured, academic curriculum roadmap.
class SyllabusModuleCard extends StatelessWidget {
  final LevelNodeModel node;
  final VoidCallback onTap;

  const SyllabusModuleCard({
    super.key,
    required this.node,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = node.state == NodeState.completed;
    final bool isActive = node.state == NodeState.active;
    final bool isBoss = node.state == NodeState.boss;
    final bool isLocked = node.state == NodeState.locked;

    final Color cardBg = isBoss
        ? const Color(0xFF0F172A)
        : (isActive ? Colors.white : (isCompleted ? const Color(0xFFFCFCFC) : const Color(0xFFF8FAFC)));

    final Color borderColor = isBoss
        ? const Color(0xFF0F172A)
        : (isActive ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0));

    final Color titleColor = isBoss
        ? Colors.white
        : (isLocked ? const Color(0xFF94A3B8) : const Color(0xFF0F172A));

    final Color subtitleColor = isBoss
        ? const Color(0xFF94A3B8)
        : (isLocked ? const Color(0xFFCBD5E1) : const Color(0xFF64748B));

    return BouncyTap(
      onTap: () {
        VocaHaptics.selection();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isActive ? 1.8 : 1.0),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Status Indicator Circle / Avatar
            _buildLeadingIndicator(isCompleted, isActive, isBoss, isLocked),
            const SizedBox(width: 14),

            // Center: Info & Objective
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Focus Type Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isBoss
                              ? const Color(0xFF1E293B)
                              : (isActive ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          node.focusLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: isBoss
                                ? const Color(0xFFE2E8F0)
                                : (isActive ? Colors.white : const Color(0xFF475569)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Level Index
                      Text(
                        'MOD ${node.unitNumber}.${node.levelNumber}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isBoss ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),

                      // XP Reward
                      Text(
                        '+${node.xpReward} XP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isBoss ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    node.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Subtitle / Pedagogical Objective
                  Text(
                    node.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right Chevron / Action Hint
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isBoss
                  ? Colors.white54
                  : (isLocked ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIndicator(bool isCompleted, bool isActive, bool isBoss, bool isLocked) {
    if (isActive) {
      // Perched Notion Avatar on active node
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0F172A), width: 2),
            ),
            child: Center(
              child: Builder(
                builder: (context) {
                  final storage = LocalStorageService();
                  return NotionAvatar(
                    head: storage.getNotionHead(),
                    hair: storage.getNotionHair(),
                    eyes: storage.getNotionEyes(),
                    mouth: storage.getNotionMouth(),
                    outfit: storage.getNotionOutfit(),
                    backdrop: storage.getNotionBackdrop(),
                    size: 40,
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'AQUÍ',
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (isCompleted) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    }

    if (isBoss) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: const Center(
          child: Icon(
            Icons.verified_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    }

    // Locked
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: const Center(
        child: Icon(
          Icons.lock_outline_rounded,
          color: Color(0xFF94A3B8),
          size: 18,
        ),
      ),
    );
  }
}
