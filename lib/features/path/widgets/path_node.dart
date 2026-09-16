import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/mascot_avatar.dart';
import '../models/level_node.dart';

class PathNode extends StatefulWidget {
  final LevelNodeModel node;
  final VoidCallback onTap;

  const PathNode({
    super.key,
    required this.node,
    required this.onTap,
  });

  @override
  State<PathNode> createState() => _PathNodeState();
}

class _PathNodeState extends State<PathNode> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxShift = (screenWidth / 2) - 80;
    final double dx = widget.node.xOffset * maxShift;

    return Transform.translate(
      offset: Offset(dx, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.node.state == NodeState.active) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: VocaColors.darkSlate,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981), // Live pulse dot
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'START',
                        style: VocaTypography.caption.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const MascotAvatar(size: 44, emotion: 'focus'),
              ],
            ),
            const SizedBox(height: 8),
          ],

          if (widget.node.state == NodeState.boss)
            _buildBossNode()
          else
            _buildMinimalistNode(),
        ],
      ),
    );
  }

  Widget _buildMinimalistNode() {
    final state = widget.node.state;
    final isCompleted = state == NodeState.completed;
    final isActive = state == NodeState.active;
    final isLocked = state == NodeState.locked;

    Color surfaceColor;
    Color borderColor;
    Color iconColor;
    IconData icon;

    if (isCompleted) {
      surfaceColor = const Color(0xFFF4F4F5);
      borderColor = const Color(0xFFE4E4E7);
      iconColor = const Color(0xFF059669);
      icon = Icons.check_rounded;
    } else if (isActive) {
      surfaceColor = const Color(0xFF4F46E5);
      borderColor = const Color(0xFF3730A3);
      iconColor = Colors.white;
      icon = Icons.play_arrow_rounded;
    } else {
      surfaceColor = const Color(0xFFFAFAFA);
      borderColor = const Color(0xFFE4E4E7);
      iconColor = const Color(0xFFA1A1AA);
      icon = Icons.lock_outline_rounded;
    }

    const double size = 64.0;
    const double depth = 3.5;

    return GestureDetector(
      onTapDown: (_) {
        if (!isLocked) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (!isLocked) {
          setState(() => _isPressed = false);
          widget.onTap();
        }
      },
      onTapCancel: () {
        if (!isLocked) setState(() => _isPressed = false);
      },
      child: SizedBox(
        width: size + 8,
        height: size + depth + 6,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Active Aura
            if (isActive)
              Container(
                width: size + 8,
                height: size + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4F46E5).withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),

            // Subtle 3D Lip
            Positioned(
              top: depth + 2,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Top Surface
            AnimatedPositioned(
              duration: const Duration(milliseconds: 40),
              curve: Curves.easeOut,
              top: _isPressed ? depth + 2 : 2,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? Colors.white.withOpacity(0.2) : borderColor,
                    width: 1.5,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBossNode() {
    const double size = 72.0;

    return BouncyTap(
      onTap: widget.onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF334155), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 6),
              blurRadius: 16,
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_none_rounded, color: Colors.white, size: 26),
            SizedBox(height: 3),
            Text(
              'BOSS',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
