import 'dart:math' as math;
import 'package:flutter/material.dart';

class HarmonicSpectrumVisualizer extends StatefulWidget {
  final bool isSpeaking;
  final Color primaryColor;
  final Color secondaryColor;
  final double height;

  const HarmonicSpectrumVisualizer({
    super.key,
    required this.isSpeaking,
    this.primaryColor = const Color(0xFF6366F1),
    this.secondaryColor = const Color(0xFF06B6D4),
    this.height = 48,
  });

  @override
  State<HarmonicSpectrumVisualizer> createState() =>
      _HarmonicSpectrumVisualizerState();
}

class _HarmonicSpectrumVisualizerState
    extends State<HarmonicSpectrumVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _HarmonicWavePainter(
              phase: _animController.value * 2 * math.pi,
              isSpeaking: widget.isSpeaking,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
            ),
          );
        },
      ),
    );
  }
}

class _HarmonicWavePainter extends CustomPainter {
  final double phase;
  final bool isSpeaking;
  final Color primaryColor;
  final Color secondaryColor;

  _HarmonicWavePainter({
    required this.phase,
    required this.isSpeaking,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final width = size.width;
    final amplitude = isSpeaking ? (size.height * 0.40) : (size.height * 0.10);

    // 1. First Wave (Primary)
    final path1 = Path();
    path1.moveTo(0, midY);
    for (double x = 0; x <= width; x += 3) {
      final normX = x / width;
      final envelope = math.sin(normX * math.pi); // Taper at edges
      final y = midY +
          math.sin((normX * 3.5 * math.pi) + phase) * amplitude * envelope;
      path1.lineTo(x, y);
    }

    final paint1 = Paint()
      ..color = primaryColor.withOpacity(isSpeaking ? 0.9 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path1, paint1);

    // 2. Second Wave (Secondary, Higher Frequency, Inverted Phase)
    final path2 = Path();
    path2.moveTo(0, midY);
    for (double x = 0; x <= width; x += 3) {
      final normX = x / width;
      final envelope = math.sin(normX * math.pi);
      final y = midY +
          math.sin((normX * 5.5 * math.pi) - phase * 1.3) *
              (amplitude * 0.75) *
              envelope;
      path2.lineTo(x, y);
    }

    final paint2 = Paint()
      ..color = secondaryColor.withOpacity(isSpeaking ? 0.8 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path2, paint2);

    // 3. Floating Sound Particles when speaking
    if (isSpeaking) {
      final particlePaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < 6; i++) {
        final normX = ((i * 0.16 + (phase / (2 * math.pi)) * 0.4) % 0.9) + 0.05;
        final x = normX * width;
        final envelope = math.sin(normX * math.pi);
        final y = midY +
            math.sin((normX * 4 * math.pi) + phase) *
                (amplitude * 1.1) *
                envelope;

        particlePaint.color = (i % 2 == 0 ? primaryColor : secondaryColor)
            .withOpacity(0.7);
        canvas.drawCircle(Offset(x, y), (i % 3) + 2.0, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HarmonicWavePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.isSpeaking != isSpeaking ||
        oldDelegate.primaryColor != primaryColor;
  }
}

