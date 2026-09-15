import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          // If active, show Duolingo "START" pill banner + Mascot
          if (widget.node.state == NodeState.active) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Duolingo Floating "START" Bubble with down arrow
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Text(
                        'START',
                        style: TextStyle(
                          color: Color(0xFF58CC02),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    CustomPaint(
                      size: const Size(12, 6),
                      painter: TrianglePainter(),
                    ),
                  ],
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -5, duration: const Duration(milliseconds: 900)),
                const SizedBox(width: 8),
                const MascotAvatar(size: 48, emotion: 'excited'),
              ],
            ),
            const SizedBox(height: 6),
          ],

          if (widget.node.state == NodeState.boss)
            _buildBossNode()
          else
            _buildDuolingoNode(),
        ],
      ),
    );
  }

  Widget _buildDuolingoNode() {
    final state = widget.node.state;
    final isCompleted = state == NodeState.completed;
    final isActive = state == NodeState.active;
    final isLocked = state == NodeState.locked;

    Color surfaceColor;
    Color shadowColor;
    Widget nodeIcon;

    if (isCompleted) {
      // Golden yellow with white checkmark
      surfaceColor = const Color(0xFFFFC800);
      shadowColor = const Color(0xFFD69A00);
      nodeIcon = const Icon(Icons.check_rounded, color: Colors.white, size: 36);
    } else if (isActive) {
      // Duolingo green with glowing white ring and star/play
      surfaceColor = const Color(0xFF58CC02);
      shadowColor = const Color(0xFF46A302);
      nodeIcon = const Icon(Icons.star_rounded, color: Colors.white, size: 38);
    } else {
      // Matte grey locked button
      surfaceColor = const Color(0xFFE5E5E5);
      shadowColor = const Color(0xFFAFAFAF);
      nodeIcon = const Icon(Icons.lock_rounded, color: Color(0xFF9E9E9E), size: 30);
    }

    const double size = 74.0;
    const double depth = 6.0;

    Widget nodeButton = GestureDetector(
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
        height: size + depth + 8,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Outer Concentric Ring for Active Node (Image 3 & 4)
            if (isActive)
              Positioned(
                top: 0,
                child: Container(
                  width: size + 8,
                  height: size + depth + 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF58CC02).withOpacity(0.4),
                      width: 4,
                    ),
                  ),
                ),
              ),

            // 3D Bottom Lip / Shadow Base
            Positioned(
              top: depth + 3,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: shadowColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Top Pushable Face
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOut,
              top: _isPressed ? depth + 3 : 3,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF58CC02).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(child: nodeIcon),
              ),
            ),
          ],
        ),
      ),
    );

    return nodeButton;
  }

  Widget _buildBossNode() {
    const double size = 80.0;
    const double depth = 6.0;

    return BouncyTap(
      onTap: widget.onTap,
      child: SizedBox(
        width: size,
        height: size + depth + 4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hexagon Shadow Base
            Positioned(
              top: depth,
              child: ClipPath(
                clipper: HexagonClipper(),
                child: Container(
                  width: size,
                  height: size,
                  color: const Color(0xFFD6185D),
                ),
              ),
            ),

            // Top Surface Hexagon
            ClipPath(
              clipper: HexagonClipper(),
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF2D78), Color(0xFFFF7643)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mic_external_on_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    Text(
                      'BOSS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
