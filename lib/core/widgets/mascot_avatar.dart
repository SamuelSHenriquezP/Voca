import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/voca_colors.dart';

/// Minimalist vector-drawn mascot crest for VOCA
class MascotAvatar extends StatelessWidget {
  final double size;
  final bool isAnimated;
  final String emotion;

  const MascotAvatar({
    super.key,
    this.size = 52.0,
    this.isAnimated = true,
    this.emotion = 'happy',
  });

  @override
  Widget build(BuildContext context) {
    Widget crest = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: VocaColors.darkSlate,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: VocaBirdPainter(),
        ),
      ),
    );

    if (isAnimated) {
      return crest
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -4,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOutSine,
          );
    }

    return crest;
  }
}

/// Precise geometric minimalist bird/crest vector
class VocaBirdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body Wing (Primary Indigo)
    final bodyPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(w * 0.2, h * 0.75)
      ..cubicTo(w * 0.2, h * 0.35, w * 0.5, h * 0.15, w * 0.75, h * 0.15)
      ..cubicTo(w * 0.6, h * 0.45, w * 0.55, h * 0.7, w * 0.2, h * 0.75)
      ..close();

    canvas.drawPath(bodyPath, bodyPaint);

    // Accent Feather (Cyan / Sky)
    final wingPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    final wingPath = Path()
      ..moveTo(w * 0.3, h * 0.65)
      ..cubicTo(w * 0.45, h * 0.4, w * 0.75, h * 0.3, w * 0.85, h * 0.35)
      ..cubicTo(w * 0.7, h * 0.6, w * 0.5, h * 0.75, w * 0.3, h * 0.65)
      ..close();

    canvas.drawPath(wingPath, wingPaint);

    // Beak (Warm Amber)
    final beakPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final beakPath = Path()
      ..moveTo(w * 0.75, h * 0.22)
      ..lineTo(w * 0.98, h * 0.3)
      ..lineTo(w * 0.78, h * 0.38)
      ..close();

    canvas.drawPath(beakPath, beakPaint);

    // Eye (Crisp White dot)
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.68, h * 0.26), w * 0.055, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
