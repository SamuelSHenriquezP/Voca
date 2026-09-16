import 'package:flutter/material.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';

class ActivityVelocityChart extends StatefulWidget {
  final List<double> weeklyMinutes; // 7 days of minutes practiced

  const ActivityVelocityChart({
    super.key,
    this.weeklyMinutes = const [25, 40, 15, 65, 50, 85, 45],
  });

  @override
  State<ActivityVelocityChart> createState() => _ActivityVelocityChartState();
}

class _ActivityVelocityChartState extends State<ActivityVelocityChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _selectedDayIndex = 5; // Default to Saturday (high point)

  final List<String> _days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMin = widget.weeklyMinutes[_selectedDayIndex].toInt();
    final totalWeeklyMin = widget.weeklyMinutes.reduce((a, b) => a + b).toInt();

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRACTICE VELOCITY',
                    style: VocaTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalWeeklyMin mins total this week',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 13, color: Color(0xFF059669)),
                    SizedBox(width: 4),
                    Text(
                      '+18% vs last wk',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Active Day Inspection Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 8),
                    Text(
                      '${_days[_selectedDayIndex]} Focus:',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$selectedMin minutes active',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Smooth Bezier Curve Canvas
          SizedBox(
            height: 120,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 120),
                  painter: _VelocityChartPainter(
                    data: widget.weeklyMinutes,
                    progress: _animation.value,
                    selectedIndex: _selectedDayIndex,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Day Selector Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_days.length, (index) {
              final isSelected = _selectedDayIndex == index;
              return BouncyTap(
                onTap: () {
                  setState(() => _selectedDayIndex = index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _days[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _VelocityChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final int selectedIndex;

  _VelocityChartPainter({
    required this.data,
    required this.progress,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = (data.reduce((a, b) => a > b ? a : b) * 1.25).clamp(1.0, 500.0);
    final count = data.length;
    final stepX = size.width / (count - 1);

    final points = <Offset>[];
    for (int i = 0; i < count; i++) {
      final x = i * stepX;
      final normalizedY = (data[i] / maxVal) * progress;
      final y = size.height - (normalizedY * (size.height - 20)) - 10;
      points.add(Offset(x, y));
    }

    // 1. Draw subtle horizontal grid guidelines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Build Smooth Cubic Bezier Path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY1 = p0.dy;
      final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY2 = p1.dy;
      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    // 3. Gradient Fill Under Curve
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4F46E5).withOpacity(0.25),
          const Color(0xFF4F46E5).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 4. Draw Smooth Outline Curve
    final strokePaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // 5. Draw Vertical Indicator on Selected Day
    if (selectedIndex >= 0 && selectedIndex < points.length) {
      final selPt = points[selectedIndex];

      final dashPaint = Paint()
        ..color = const Color(0xFF4F46E5).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawLine(
        Offset(selPt.dx, selPt.dy),
        Offset(selPt.dx, size.height),
        dashPaint,
      );

      // Outer glow circle
      final glowPaint = Paint()
        ..color = const Color(0xFF4F46E5).withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selPt, 9, glowPaint);

      // Main dot
      final dotPaint = Paint()
        ..color = const Color(0xFF4F46E5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selPt, 5, dotPaint);

      // White center
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selPt, 2.5, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VelocityChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data;
  }
}
