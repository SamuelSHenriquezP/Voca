import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/notion_avatar.dart';

class NpcAvatarCard extends StatelessWidget {
  final String name;
  final String role;
  final bool isSpeaking;
  final String statusText;
  final Widget? trailing;

  const NpcAvatarCard({
    super.key,
    this.name = 'Agent Miller',
    this.role = 'Border & Customs Clearance',
    this.isSpeaking = false,
    this.statusText = 'Ready',
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (statusText.contains('Speaking')) {
      statusColor = const Color(0xFF38BDF8);
    } else if (statusText.contains('Listening')) {
      statusColor = const Color(0xFF10B981);
    } else {
      statusColor = const Color(0xFF94A3B8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          // Compact Vector Notion Ink Avatar
          NotionAvatar.fromId(
            name,
            size: 42,
            isAnimated: isSpeaking,
          ),
          const SizedBox(width: 12),

          // Name, Role & Status Dot
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.3, 1.3),
                          duration: const Duration(milliseconds: 600),
                        ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Custom Vector Illustration for the Officer Persona (No emojis)
class OfficerVectorPainter extends CustomPainter {
  final Color color;

  const OfficerVectorPainter({this.color = const Color(0xFFE2E8F0)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    // Officer Cap Peak
    final capPath = Path();
    capPath.moveTo(w * 0.22, h * 0.36);
    capPath.quadraticBezierTo(w * 0.5, h * 0.22, w * 0.78, h * 0.36);
    capPath.lineTo(w * 0.85, h * 0.42);
    capPath.quadraticBezierTo(w * 0.5, h * 0.38, w * 0.15, h * 0.42);
    capPath.close();

    canvas.drawPath(capPath, fillPaint);
    canvas.drawPath(capPath, strokePaint);

    // Cap Visor Arc
    final visorPath = Path();
    visorPath.moveTo(w * 0.2, h * 0.42);
    visorPath.quadraticBezierTo(w * 0.5, h * 0.48, w * 0.8, h * 0.42);
    canvas.drawPath(visorPath, strokePaint);

    // Head Oval
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.34, height: h * 0.36),
      strokePaint,
    );

    // Officer Uniform Shoulders
    final shoulderPath = Path();
    shoulderPath.moveTo(w * 0.12, h * 0.94);
    shoulderPath.quadraticBezierTo(w * 0.25, h * 0.76, w * 0.4, h * 0.74);
    shoulderPath.lineTo(w * 0.6, h * 0.74);
    shoulderPath.quadraticBezierTo(w * 0.75, h * 0.76, w * 0.88, h * 0.94);
    canvas.drawPath(shoulderPath, strokePaint);

    // Tie / Collar Line
    canvas.drawLine(Offset(w * 0.5, h * 0.74), Offset(w * 0.5, h * 0.92), strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
