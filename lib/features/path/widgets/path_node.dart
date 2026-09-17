import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/adventure_cartoon_avatar.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/level_node.dart';

class PathNode extends StatelessWidget {
  final LevelNodeModel node;
  final VoidCallback onTap;

  const PathNode({
    super.key,
    required this.node,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxShift = (screenWidth / 2) - 80;
    final double dx = node.xOffset * maxShift;

    return Transform.translate(
      offset: Offset(dx, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active Indicator Badge & Mascot
          if (node.state == NodeState.active) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AQUÍ',
                        style: VocaTypography.caption.copyWith(
                          color: const Color(0xFF4F46E5),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) {
                    final storage = LocalStorageService();
                    final archStr = storage.getHeroArchetype();
                    final arch = AdventureArchetype.values.firstWhere(
                      (a) => a.name == archStr,
                      orElse: () => AdventureArchetype.finn,
                    );
                    final heroColor = storage.getHeroColor();

                    return AdventureCartoonAvatar(
                      archetype: arch,
                      size: 42,
                      customColor: Color(heroColor),
                      expression: 'happy',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Minimalist Flat Level Circle
          _buildNodeCircle(context),
        ],
      ),
    );
  }

  Widget _buildNodeCircle(BuildContext context) {
    final state = node.state;
    final isCompleted = state == NodeState.completed;
    final isActive = state == NodeState.active;
    final isBoss = state == NodeState.boss;
    final isLocked = state == NodeState.locked;

    const double size = 66.0;

    Color bg;
    Color border;
    Color iconColor;
    IconData icon;

    if (isCompleted) {
      bg = const Color(0xFFECFDF5); // Soft Mint
      border = const Color(0xFFA7F3D0);
      iconColor = const Color(0xFF10B981);
      icon = Icons.check_rounded;
    } else if (isActive) {
      bg = const Color(0xFF6366F1); // Vibrant Violet
      border = const Color(0xFF4F46E5);
      iconColor = Colors.white;
      icon = Icons.play_arrow_rounded;
    } else if (isBoss) {
      bg = const Color(0xFF8B5CF6); // Royal Violet
      border = const Color(0xFF7C3AED);
      iconColor = Colors.white;
      icon = Icons.emoji_events_rounded;
    } else {
      bg = const Color(0xFFF8FAFC); // Clean Light Slate
      border = const Color(0xFFE2E8F0);
      iconColor = const Color(0xFF94A3B8);
      icon = Icons.lock_rounded;
    }

    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: isActive || isBoss ? 2.5 : 2.0),
        boxShadow: (isActive || isBoss)
            ? [
                BoxShadow(
                  color: bg.withOpacity(0.28),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: iconColor, size: isCompleted ? 30 : 32),
          if (isCompleted)
            Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => const Icon(
                    Icons.star_rounded,
                    size: 11,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (isActive) {
      circle = circle
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.07, 1.07),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
          );
    }

    return BouncyTap(
      onTap: onTap,
      scaleFactor: isLocked ? 1.0 : 0.94,
      child: circle,
    );
  }
}
