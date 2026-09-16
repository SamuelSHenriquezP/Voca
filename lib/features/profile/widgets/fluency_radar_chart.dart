import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';

class FluencyRadarChart extends StatefulWidget {
  final Map<String, double> skills; // values from 0.0 to 1.0

  const FluencyRadarChart({
    super.key,
    this.skills = const {
      'Pronunciation': 0.88,
      'Fluency': 0.74,
      'Vocabulary': 0.92,
      'Grammar': 0.82,
      'Listening': 0.85,
    },
  });

  @override
  State<FluencyRadarChart> createState() => _FluencyRadarChartState();
}

class _FluencyRadarChartState extends State<FluencyRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _showTargetBenchmark = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FLUENCY MATRIX',
                    style: VocaTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Multi-dimensional spoken proficiency',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              BouncyTap(
                onTap: () {
                  setState(() {
                    _showTargetBenchmark = !_showTargetBenchmark;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _showTargetBenchmark
                        ? const Color(0xFFEEF2FF)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _showTargetBenchmark
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        size: 14,
                        color: _showTargetBenchmark
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showTargetBenchmark ? 'C1 Target' : 'Benchmark',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _showTargetBenchmark
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Radar Chart Canvas
          Center(
            child: SizedBox(
              width: 260,
              height: 240,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(260, 240),
                    painter: _RadarChartPainter(
                      skills: widget.skills,
                      progress: _animation.value,
                      showTarget: _showTargetBenchmark,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Legend / Skill Breakdown Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.skills.entries.map((entry) {
              final percentage = (entry.value * 100).toInt();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> skills;
  final double progress;
  final bool showTarget;

  _RadarChartPainter({
    required this.skills,
    required this.progress,
    required this.showTarget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.38;
    final keys = skills.keys.toList();
    final count = keys.length;
    if (count < 3) return;

    final angleStep = (math.pi * 2) / count;
    const startAngle = -math.pi / 2;

    // 1. Draw Web Rings (concentric polygons)
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final ringSteps = [0.25, 0.50, 0.75, 1.0];
    for (final step in ringSteps) {
      final ringPath = Path();
      for (int i = 0; i < count; i++) {
        final angle = startAngle + i * angleStep;
        final r = radius * step;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    // 2. Draw Radial Axis Lines
    final axisPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < count; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);
    }

    // 3. Draw Target C1 Benchmark polygon if active
    if (showTarget) {
      const targetValues = [0.95, 0.90, 0.92, 0.95, 0.95];
      final targetPath = Path();
      for (int i = 0; i < count; i++) {
        final angle = startAngle + i * angleStep;
        final val = targetValues[i % targetValues.length] * progress;
        final r = radius * val;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          targetPath.moveTo(x, y);
        } else {
          targetPath.lineTo(x, y);
        }
      }
      targetPath.close();

      final targetFillPaint = Paint()
        ..color = const Color(0xFF0284C7).withOpacity(0.08)
        ..style = PaintingStyle.fill;
      final targetStrokePaint = Paint()
        ..color = const Color(0xFF0284C7).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawPath(targetPath, targetFillPaint);
      canvas.drawPath(targetPath, targetStrokePaint);
    }

    // 4. Draw Current User Skill Polygon
    final userPath = Path();
    final points = <Offset>[];
    for (int i = 0; i < count; i++) {
      final angle = startAngle + i * angleStep;
      final value = (skills[keys[i]] ?? 0.0) * progress;
      final r = radius * value;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      final point = Offset(x, y);
      points.add(point);
      if (i == 0) {
        userPath.moveTo(x, y);
      } else {
        userPath.lineTo(x, y);
      }
    }
    userPath.close();

    // User Fill (Indigo tint)
    final userFillPaint = Paint()
      ..color = const Color(0xFF4F46E5).withOpacity(0.20)
      ..style = PaintingStyle.fill;
    canvas.drawPath(userPath, userFillPaint);

    // User Outline
    final userStrokePaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(userPath, userStrokePaint);

    // 5. Draw Vertex Dots
    final dotPaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.fill;
    final dotRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final pt in points) {
      canvas.drawCircle(pt, 4.5, dotPaint);
      canvas.drawCircle(pt, 4.5, dotRingPaint);
    }

    // 6. Draw Text Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < count; i++) {
      final angle = startAngle + i * angleStep;
      final labelRadius = radius + 22;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final label = keys[i];
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      );
      textPainter.layout();
      final offset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.showTarget != showTarget ||
        oldDelegate.skills != skills;
  }
}
