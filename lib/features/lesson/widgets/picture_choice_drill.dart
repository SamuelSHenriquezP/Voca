import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/exercise.dart';

class PictureChoiceDrill extends StatelessWidget {
  final ExerciseModel exercise;
  final String? selectedOptionId;
  final Function(PictureChoiceOption option) onOptionSelected;

  const PictureChoiceDrill({
    super.key,
    required this.exercise,
    required this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'VOCABULARY DRILL',
            style: TextStyle(
              color: Color(0xFF4F46E5),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Prompt
        Text(
          'Select the correct visual representation',
          style: VocaTypography.heading1.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: VocaColors.darkSlate,
          ),
        ),
        const SizedBox(height: 10),

        // Audio Prompt Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: Color(0xFF4F46E5),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'The Check / Bill',
              style: VocaTypography.heading2.copyWith(
                fontSize: 17,
                color: const Color(0xFF4F46E5),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '/ðə tʃɛk/',
              style: VocaTypography.caption.copyWith(color: VocaColors.textMuted),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 2x2 Custom Vector Illustrated Cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.92,
          ),
          itemCount: exercise.pictureOptions.length,
          itemBuilder: (context, index) {
            final option = exercise.pictureOptions[index];
            final isSelected = selectedOptionId == option.id;

            return BouncyTap(
              onTap: () {
                HapticUtils.selection();
                onOptionSelected(option);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                    width: isSelected ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF4F46E5).withOpacity(0.12)
                          : Colors.black.withOpacity(0.02),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Vector Drawn Real-World Artwork (CustomPainter, Zero Emojis)
                    Expanded(
                      child: Center(
                        child: _buildVectorIllustration(option.id, isSelected),
                      ),
                    ),

                    // Label
                    Column(
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.audioPhonetic,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
          },
        ),
      ],
    );
  }

  Widget _buildVectorIllustration(String id, bool isSelected) {
    switch (id) {
      case 'opt_bill':
        return CustomPaint(
          size: const Size(60, 60),
          painter: ReceiptVectorPainter(accentColor: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
        );
      case 'opt_menu':
        return CustomPaint(
          size: const Size(60, 60),
          painter: MenuVectorPainter(accentColor: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
        );
      case 'opt_waiter':
        return CustomPaint(
          size: const Size(60, 60),
          painter: ClocheVectorPainter(accentColor: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
        );
      case 'opt_fork':
      default:
        return CustomPaint(
          size: const Size(60, 60),
          painter: CutleryVectorPainter(accentColor: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
        );
    }
  }
}

/// Vector Painter 1: Precision Restaurant Receipt (The Bill)
class ReceiptVectorPainter extends CustomPainter {
  final Color accentColor;
  ReceiptVectorPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Receipt Paper
    final paperPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final paperPath = Path();
    paperPath.moveTo(w * 0.2, h * 0.1);
    paperPath.lineTo(w * 0.8, h * 0.1);
    paperPath.lineTo(w * 0.8, h * 0.9);
    // Serrated bottom edge
    paperPath.lineTo(w * 0.7, h * 0.85);
    paperPath.lineTo(w * 0.6, h * 0.9);
    paperPath.lineTo(w * 0.5, h * 0.85);
    paperPath.lineTo(w * 0.4, h * 0.9);
    paperPath.lineTo(w * 0.3, h * 0.85);
    paperPath.lineTo(w * 0.2, h * 0.9);
    paperPath.close();

    canvas.drawPath(paperPath, paperPaint);
    canvas.drawPath(paperPath, borderPaint);

    // Receipt Text Lines
    final linePaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.32, h * 0.25), Offset(w * 0.68, h * 0.25), linePaint);
    canvas.drawLine(Offset(w * 0.32, h * 0.38), Offset(w * 0.55, h * 0.38), linePaint);
    canvas.drawLine(Offset(w * 0.32, h * 0.50), Offset(w * 0.62, h * 0.50), linePaint);

    // Total Bold Line
    final totalPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.32, h * 0.68), Offset(w * 0.68, h * 0.68), totalPaint);
  }

  @override
  bool shouldRepaint(covariant ReceiptVectorPainter oldDelegate) => oldDelegate.accentColor != accentColor;
}

/// Vector Painter 2: Restaurant Menu Book
class MenuVectorPainter extends CustomPainter {
  final Color accentColor;
  MenuVectorPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final borderPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.12, w * 0.56, h * 0.76),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, borderPaint);

    // Spine
    final spinePaint = Paint()
      ..color = accentColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.22, h * 0.12, w * 0.1, h * 0.76), const Radius.circular(4)),
      spinePaint,
    );

    // Menu emblem / lines
    final linePaint = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.42, h * 0.32), Offset(w * 0.66, h * 0.32), linePaint);
    canvas.drawLine(Offset(w * 0.42, h * 0.44), Offset(w * 0.66, h * 0.44), linePaint);
    canvas.drawLine(Offset(w * 0.42, h * 0.56), Offset(w * 0.58, h * 0.56), linePaint);
  }

  @override
  bool shouldRepaint(covariant MenuVectorPainter oldDelegate) => oldDelegate.accentColor != accentColor;
}

/// Vector Painter 3: Serving Cloche / Plate (The Waiter)
class ClocheVectorPainter extends CustomPainter {
  final Color accentColor;
  ClocheVectorPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dome Arc
    final domePath = Path();
    domePath.moveTo(w * 0.15, h * 0.65);
    domePath.quadraticBezierTo(w * 0.18, h * 0.28, w * 0.5, h * 0.28);
    domePath.quadraticBezierTo(w * 0.82, h * 0.28, w * 0.85, h * 0.65);
    canvas.drawPath(domePath, strokePaint);

    // Base Platter Tray
    canvas.drawLine(Offset(w * 0.1, h * 0.65), Offset(w * 0.9, h * 0.65), strokePaint);
    canvas.drawLine(Offset(w * 0.18, h * 0.72), Offset(w * 0.82, h * 0.72), strokePaint);

    // Handle Knob
    canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.05, strokePaint);
  }

  @override
  bool shouldRepaint(covariant ClocheVectorPainter oldDelegate) => oldDelegate.accentColor != accentColor;
}

/// Vector Painter 4: Modern Minimalist Fork & Knife (Cutlery)
class CutleryVectorPainter extends CustomPainter {
  final Color accentColor;
  CutleryVectorPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Fork (Left)
    canvas.drawLine(Offset(w * 0.35, h * 0.15), Offset(w * 0.35, h * 0.85), strokePaint);
    canvas.drawLine(Offset(w * 0.28, h * 0.15), Offset(w * 0.28, h * 0.45), strokePaint);
    canvas.drawLine(Offset(w * 0.42, h * 0.15), Offset(w * 0.42, h * 0.45), strokePaint);
    canvas.drawLine(Offset(w * 0.28, h * 0.45), Offset(w * 0.42, h * 0.45), strokePaint);

    // Knife (Right)
    final knifePath = Path();
    knifePath.moveTo(w * 0.65, h * 0.85);
    knifePath.lineTo(w * 0.65, h * 0.15);
    knifePath.quadraticBezierTo(w * 0.78, h * 0.3, w * 0.65, h * 0.5);
    canvas.drawPath(knifePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CutleryVectorPainter oldDelegate) => oldDelegate.accentColor != accentColor;
}
