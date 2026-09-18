import 'package:flutter/material.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/voca_avatar.dart';
import 'npc_avatar_card.dart';

class ScenarioItem {
  final String id;
  final String title;
  final String personaName;
  final String personaRole;
  final String description;
  final String difficulty;
  final Color accentColor;
  final Widget iconWidget;
  final String openingMessage;
  final String suggestedPhrase;
  final String hintContext;

  const ScenarioItem({
    required this.id,
    required this.title,
    required this.personaName,
    required this.personaRole,
    required this.description,
    required this.difficulty,
    required this.accentColor,
    required this.iconWidget,
    required this.openingMessage,
    required this.suggestedPhrase,
    required this.hintContext,
  });
}

class ScenarioSelectorSheet extends StatelessWidget {
  final String selectedId;
  final Function(ScenarioItem scenario) onSelectScenario;

  const ScenarioSelectorSheet({
    super.key,
    required this.selectedId,
    required this.onSelectScenario,
  });

  static List<ScenarioItem> get scenarios => const [
        ScenarioItem(
          id: 'alex_free_chat',
          title: 'Free Conversation with Alex',
          personaName: 'Alex',
          personaRole: 'Native English Companion',
          description: 'Spontaneous, adaptive, judgment-free talk about anything you want.',
          difficulty: 'Adaptive',
          accentColor: Color(0xFF6366F1),
          iconWidget: Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.white,
            size: 24,
          ),
          openingMessage:
              "Hey there! I'm Alex. So great to meet you! How has your day been treating you so far?",
          suggestedPhrase:
              '"Hey Alex! My day has been pretty good, just practicing my spoken English."',
          hintContext:
              'Speak freely! Alex adapts dynamically to your pace, keeps answers brief, and provides gentle feedback.',
        ),
        ScenarioItem(
          id: 'jfk_customs',
          title: 'Airport Customs Inspection',
          personaName: 'Officer Miller',
          personaRole: 'US Border & Customs Patrol',
          description: 'Answer declaration inquiries and declare your length of stay.',
          difficulty: 'Intermediate',
          accentColor: Color(0xFF4F46E5),
          iconWidget: CustomPaint(
            size: Size(28, 28),
            painter: OfficerVectorPainter(color: Colors.white),
          ),
          openingMessage:
              'Good afternoon. What is the primary purpose of your visit to the United States?',
          suggestedPhrase:
              '"I will be staying for two weeks for vacation and visiting family in Seattle."',
          hintContext:
              'Customs officers expect concise, direct statements regarding your itinerary and accommodation.',
        ),
        ScenarioItem(
          id: 'coffee_barista',
          title: 'Manhattan Specialty Coffee',
          personaName: 'Barista Mateo',
          personaRole: 'Head Roaster & Barista',
          description: 'Order bespoke coffee with milk substitutes, sizes, and customizations.',
          difficulty: 'Elementary',
          accentColor: Color(0xFFD97706),
          iconWidget: CustomPaint(
            size: Size(28, 28),
            painter: _CoffeeCupVectorPainter(color: Colors.white),
          ),
          openingMessage:
              'Hey there! What can I craft for you today from the espresso bar?',
          suggestedPhrase:
              '"Could I get a flat white with oat milk, extra hot, to go please?"',
          hintContext:
              'Baristas appreciate quick drink orders followed by milk choice, temperature, and for here or to go.',
        ),
        ScenarioItem(
          id: 'tech_interview',
          title: 'Silicon Valley Job Interview',
          personaName: 'Director Marcus',
          personaRole: 'VP of Product Engineering',
          description: 'Explain past technical achievements and handle situational behavioral prompts.',
          difficulty: 'Advanced',
          accentColor: Color(0xFF0284C7),
          iconWidget: CustomPaint(
            size: Size(28, 28),
            painter: _LaptopVectorPainter(color: Colors.white),
          ),
          openingMessage:
              'Welcome Marcus. Could you summarize a challenging engineering deadlock you resolved recently?',
          suggestedPhrase:
              '"In my previous project, we encountered severe latency bottlenecks which I mitigated via asynchronous caching."',
          hintContext:
              'Use the STAR method: Situation, Task, Action, and Measurable Result.',
        ),
        ScenarioItem(
          id: 'hotel_concierge',
          title: 'SoHo Boutique Hotel Check-in',
          personaName: 'Concierge Pierre',
          personaRole: 'Lead Hospitality Concierge',
          description: 'Request room upgrades, early check-in, and local dinner reservations.',
          difficulty: 'Intermediate',
          accentColor: Color(0xFF059669),
          iconWidget: CustomPaint(
            size: Size(28, 28),
            painter: _HotelBellVectorPainter(color: Colors.white),
          ),
          openingMessage:
              'Good evening. Welcome to The Crosby. May I request your reservation confirmation details?',
          suggestedPhrase:
              '"Good evening! I have a reservation under Rivera for 3 nights, and was hoping for a quiet high-floor room."',
          hintContext:
              'Polite greeting with reservation surname, followed by courteous requests using "I was wondering if...".',
        ),
      ];

  static void show(
    BuildContext context, {
    required String selectedId,
    required Function(ScenarioItem) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ScenarioSelectorSheet(
        selectedId: selectedId,
        onSelectScenario: (sc) {
          Navigator.of(ctx).pop();
          onSelect(sc);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'VOICE ROLEPLAY ARENAS',
              style: VocaTypography.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select a real-world scenario to practice live spoken dialogue',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Scenario Cards List
            for (final sc in scenarios) ...[
              _buildScenarioCard(sc),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioCard(ScenarioItem sc) {
    final isSelected = sc.id == selectedId;

    return BouncyTap(
      onTap: () {
        VocaHaptics.selection();
        onSelectScenario(sc);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? sc.accentColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: sc.accentColor.withOpacity(0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // VOCA Ink Avatar
            VocaAvatar.fromId(
              sc.id,
              size: 50,
              isAnimated: false,
            ),
            const SizedBox(width: 14),

            // Scenario Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sc.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: sc.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sc.difficulty.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: sc.accentColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${sc.personaName} • ${sc.personaRole}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sc.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 1. Coffee Cup Vector Painter (Zero Emojis)
class _CoffeeCupVectorPainter extends CustomPainter {
  final Color color;
  const _CoffeeCupVectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    // Cup body
    final cupPath = Path()
      ..moveTo(size.width * 0.22, size.height * 0.35)
      ..lineTo(size.width * 0.26, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.85, size.width * 0.74, size.height * 0.75)
      ..lineTo(size.width * 0.78, size.height * 0.35)
      ..close();

    canvas.drawPath(cupPath, fillPaint);
    canvas.drawPath(cupPath, paint);

    // Cup handle
    final handlePath = Path()
      ..moveTo(size.width * 0.78, size.height * 0.42)
      ..cubicTo(size.width * 0.96, size.height * 0.42, size.width * 0.96, size.height * 0.65, size.width * 0.75, size.height * 0.68);
    canvas.drawPath(handlePath, paint);

    // Saucer line
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.88),
      Offset(size.width * 0.85, size.height * 0.88),
      paint,
    );

    // Steam lines
    final steamPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.40, size.height * 0.25),
      Offset(size.width * 0.40, size.height * 0.15),
      steamPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.23),
      Offset(size.width * 0.55, size.height * 0.12),
      steamPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Laptop Vector Painter (Zero Emojis)
class _LaptopVectorPainter extends CustomPainter {
  final Color color;
  const _LaptopVectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Screen
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.20, size.height * 0.22, size.width * 0.60, size.height * 0.46),
      const Radius.circular(3),
    );
    canvas.drawRRect(screenRect, paint);

    // Base
    final basePath = Path()
      ..moveTo(size.width * 0.10, size.height * 0.74)
      ..lineTo(size.width * 0.90, size.height * 0.74)
      ..lineTo(size.width * 0.84, size.height * 0.84)
      ..lineTo(size.width * 0.16, size.height * 0.84)
      ..close();

    canvas.drawPath(basePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Hotel Service Bell Vector Painter (Zero Emojis)
class _HotelBellVectorPainter extends CustomPainter {
  final Color color;
  const _HotelBellVectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dome
    final domePath = Path()
      ..moveTo(size.width * 0.20, size.height * 0.68)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.15, size.width * 0.80, size.height * 0.68)
      ..close();
    canvas.drawPath(domePath, paint);

    // Top button
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.24), 2.5, paint);

    // Base plate
    canvas.drawLine(
      Offset(size.width * 0.14, size.height * 0.76),
      Offset(size.width * 0.86, size.height * 0.76),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
