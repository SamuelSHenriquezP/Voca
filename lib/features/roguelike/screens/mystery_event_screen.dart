import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/voca_button.dart';
import '../story/chronicles_lore.dart';

class MysteryEventScreen extends StatefulWidget {
  final MysteryStoryEvent event;
  final int playerHp;
  final int playerMaxHp;

  const MysteryEventScreen({
    super.key,
    required this.event,
    required this.playerHp,
    required this.playerMaxHp,
  });

  @override
  State<MysteryEventScreen> createState() => _MysteryEventScreenState();
}

class _MysteryEventScreenState extends State<MysteryEventScreen> {
  MysteryEventChoice? _selectedChoice;
  late int _currentHp;

  @override
  void initState() {
    super.initState();
    _currentHp = widget.playerHp;
  }

  void _choose(MysteryEventChoice choice) {
    VocaHaptics.medium();
    setState(() {
      _selectedChoice = choice;
      _currentHp = (_currentHp + choice.healthChange).clamp(0, widget.playerMaxHp);
    });
  }

  void _finishAndExit() {
    Navigator.of(context).pop({
      'playerHp': _currentHp,
      'scoreBonus': _selectedChoice?.scoreChange ?? 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.help_outline_rounded,
                            color: Color(0xFFA78BFA), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          event.locationName.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFA78BFA),
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite_rounded,
                            color: Color(0xFFEF4444), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '$_currentHp / ${widget.playerMaxHp}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 2. Event Title & Story Monologue
              Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  event.storyPrompt,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const Spacer(),

              // 3. Choices or Outcome
              if (_selectedChoice == null) ...[
                const Text(
                  'CHOOSE YOUR ACTION:',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(event.choices.length, (index) {
                  final choice = event.choices[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BouncyTap(
                      onTap: () => _choose(choice),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF475569)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                choice.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 14, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Color(0xFF34D399), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'CONSEQUENCE',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedChoice!.outcomeDescription,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                VocaButton(
                  text: 'CONTINUE EXPEDITION',
                  variant: VocaButtonVariant.cyan,
                  onPressed: _finishAndExit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
