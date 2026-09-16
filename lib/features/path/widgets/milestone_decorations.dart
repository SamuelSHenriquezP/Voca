import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';

// 1. Geometric Checkpoint Gate (Zero emojis)
class MilestoneCheckpointGate extends StatelessWidget {
  final String title;
  final bool isPassed;

  const MilestoneCheckpointGate({
    super.key,
    required this.title,
    this.isPassed = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isPassed ? const Color(0xFF059669) : const Color(0xFF4F46E5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activeColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 6),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            CustomPaint(
              size: const Size(40, 40),
              painter: _GateVectorPainter(color: activeColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: activeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPassed ? 'STAGE CLEARED' : 'CHECKPOINT GATE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: activeColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isPassed ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
              color: isPassed ? const Color(0xFF059669) : const Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _GateVectorPainter extends CustomPainter {
  final Color color;
  _GateVectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Portal archway
    final path = Path()
      ..moveTo(size.width * 0.20, size.height * 0.90)
      ..lineTo(size.width * 0.20, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.10, size.width * 0.80, size.height * 0.45)
      ..lineTo(size.width * 0.80, size.height * 0.90);

    canvas.drawPath(path, stroke);

    // Inner arch fill
    final innerPath = Path()
      ..moveTo(size.width * 0.32, size.height * 0.90)
      ..lineTo(size.width * 0.32, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.28, size.width * 0.68, size.height * 0.55)
      ..lineTo(size.width * 0.68, size.height * 0.90);

    canvas.drawPath(innerPath, fill);
    canvas.drawPath(innerPath, stroke);

    // Keystone dot
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.18), 3.0, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Interactive Animated Treasure Chest (Zero emojis)
class MilestoneRewardChest extends StatefulWidget {
  final int gemsReward;
  final VoidCallback onClaimed;

  const MilestoneRewardChest({
    super.key,
    this.gemsReward = 25,
    required this.onClaimed,
  });

  @override
  State<MilestoneRewardChest> createState() => _MilestoneRewardChestState();
}

class _MilestoneRewardChestState extends State<MilestoneRewardChest>
    with SingleTickerProviderStateMixin {
  bool _isClaimed = false;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _claim() {
    if (_isClaimed) return;
    VocaHaptics.success();
    _sparkleController.forward(from: 0.0);
    setState(() => _isClaimed = true);
    widget.onClaimed();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: BouncyTap(
          onTap: _claim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isClaimed ? const Color(0xFF059669) : const Color(0xFFD97706),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isClaimed ? const Color(0xFF059669) : const Color(0xFFD97706))
                      .withOpacity(0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(26, 26),
                  painter: _ChestVectorPainter(
                    color: _isClaimed ? const Color(0xFF059669) : const Color(0xFFD97706),
                    isOpen: _isClaimed,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isClaimed ? 'REWARD CLAIMED' : 'BONUS CACHE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _isClaimed ? const Color(0xFF059669) : const Color(0xFFD97706),
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      _isClaimed ? '+${widget.gemsReward} Gems Added' : 'Tap to unlock +${widget.gemsReward} Gems',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChestVectorPainter extends CustomPainter {
  final Color color;
  final bool isOpen;

  _ChestVectorPainter({required this.color, required this.isOpen});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Chest base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.45, size.width * 0.70, size.height * 0.45),
      const Radius.circular(4),
    );
    canvas.drawRRect(baseRect, fillPaint);
    canvas.drawRRect(baseRect, paint);

    // Lid
    if (isOpen) {
      // Tilted open lid
      final lidPath = Path()
        ..moveTo(size.width * 0.15, size.height * 0.45)
        ..lineTo(size.width * 0.20, size.height * 0.15)
        ..lineTo(size.width * 0.80, size.height * 0.25)
        ..lineTo(size.width * 0.85, size.height * 0.45);
      canvas.drawPath(lidPath, paint);
    } else {
      // Closed lid
      final lidPath = Path()
        ..moveTo(size.width * 0.12, size.height * 0.45)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.15, size.width * 0.88, size.height * 0.45)
        ..close();
      canvas.drawPath(lidPath, fillPaint);
      canvas.drawPath(lidPath, paint);
    }

    // Keyhole/Latch
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.60), 2.0, paint);
  }

  @override
  bool shouldRepaint(covariant _ChestVectorPainter oldDelegate) {
    return oldDelegate.isOpen != isOpen || oldDelegate.color != color;
  }
}
