import 'dart:math' as math;
import 'package:flutter/material.dart';

class CurvedPathConnector extends StatefulWidget {
  final double startOffset; // -1.0 to 1.0 horizontal shift of previous node
  final double endOffset;   // -1.0 to 1.0 horizontal shift of next node
  final bool isCompleted;
  final bool isActive;
  final double height;

  const CurvedPathConnector({
    super.key,
    required this.startOffset,
    required this.endOffset,
    this.isCompleted = false,
    this.isActive = false,
    this.height = 46.0,
  });

  @override
  State<CurvedPathConnector> createState() => _CurvedPathConnectorState();
}

class _CurvedPathConnectorState extends State<CurvedPathConnector>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.isActive || widget.isCompleted) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CurvedPathConnector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.isActive || widget.isCompleted) && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!widget.isActive && !widget.isCompleted && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxShift = (screenWidth / 2) - 80;
    final startX = (screenWidth / 2) + (widget.startOffset * maxShift);
    final endX = (screenWidth / 2) + (widget.endOffset * maxShift);

    return SizedBox(
      width: screenWidth,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          return CustomPaint(
            size: Size(screenWidth, widget.height),
            painter: _CurvedPathPainter(
              startX: startX,
              endX: endX,
              height: widget.height,
              isCompleted: widget.isCompleted,
              isActive: widget.isActive,
              progress: _pulseController.value,
            ),
          );
        },
      ),
    );
  }
}

class _CurvedPathPainter extends CustomPainter {
  final double startX;
  final double endX;
  final double height;
  final bool isCompleted;
  final bool isActive;
  final double progress;

  _CurvedPathPainter({
    required this.startX,
    required this.endX,
    required this.height,
    required this.isCompleted,
    required this.isActive,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Build smooth cubic bezier connecting startX to endX
    final path = Path()
      ..moveTo(startX, 0)
      ..cubicTo(
        startX,
        height * 0.52,
        endX,
        height * 0.48,
        endX,
        height,
      );

    // 2. Base soft shadow track
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, shadowPaint);

    // 3. Main road line
    Color trackColor;
    if (isCompleted) {
      trackColor = const Color(0xFFD1FAE5); // Soft emerald tint
    } else if (isActive) {
      trackColor = const Color(0xFFEEF2FF); // Soft indigo tint
    } else {
      trackColor = const Color(0xFFF1F5F9); // Slate neutral
    }

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, trackPaint);

    // 4. Stepping stones / dashes along the curve
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final length = metric.length;

    const double stepDistance = 14.0;
    final int stoneCount = (length / stepDistance).floor();

    Color stoneColor;
    Color stoneBorder;
    if (isCompleted) {
      stoneColor = const Color(0xFF10B981);
      stoneBorder = const Color(0xFF059669);
    } else if (isActive) {
      stoneColor = const Color(0xFF6366F1);
      stoneBorder = const Color(0xFF4F46E5);
    } else {
      stoneColor = const Color(0xFFCBD5E1);
      stoneBorder = const Color(0xFF94A3B8);
    }

    final stonePaint = Paint()..style = PaintingStyle.fill;
    final stoneStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i <= stoneCount; i++) {
      final distance = i * stepDistance;
      if (distance > length) break;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent == null) continue;

      final pos = tangent.position;
      final normal = Offset(-tangent.vector.dy, tangent.vector.dx);

      // Cute alternating stones offset slightly left and right
      final alt = (i % 2 == 0 ? 1 : -1) * 1.5;
      final stoneCenter = pos + (normal * alt);

      stonePaint.color = stoneColor;
      stoneStroke.color = stoneBorder;

      // Draw oval stepping stone rotated along path tangent
      canvas.save();
      canvas.translate(stoneCenter.dx, stoneCenter.dy);
      final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);
      canvas.rotate(angle);

      final stoneRect = Rect.fromCenter(center: Offset.zero, width: 6.5, height: 3.8);
      canvas.drawOval(stoneRect, stonePaint);
      canvas.drawOval(stoneRect, stoneStroke);
      canvas.restore();
    }

    // 5. Animated Energy Runner Particle (if active or completed)
    if (isActive || isCompleted) {
      final runnerDistance = (progress * length);
      final runnerTangent = metric.getTangentForOffset(runnerDistance);
      if (runnerTangent != null) {
        final pos = runnerTangent.position;

        // Outer glow
        final glowPaint = Paint()
          ..color = (isActive ? const Color(0xFF818CF8) : const Color(0xFF34D399)).withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(pos, 6.0, glowPaint);

        // Core bright spark
        final sparkPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 2.5, sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedPathPainter oldDelegate) {
    return oldDelegate.startX != startX ||
        oldDelegate.endX != endX ||
        oldDelegate.height != height ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.isActive != isActive ||
        oldDelegate.progress != progress;
  }
}

