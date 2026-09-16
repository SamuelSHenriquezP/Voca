import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';

class BlitzQuestion {
  final String prompt;
  final String category;
  final List<String> options;
  final int correctIndex;
  final String spokenModelAnswer;

  const BlitzQuestion({
    required this.prompt,
    required this.category,
    required this.options,
    required this.correctIndex,
    required this.spokenModelAnswer,
  });
}

class SpeedBlitzGame extends StatefulWidget {
  final VoidCallback onVictory;
  final VoidCallback onDefeat;

  const SpeedBlitzGame({
    super.key,
    required this.onVictory,
    required this.onDefeat,
  });

  @override
  State<SpeedBlitzGame> createState() => _SpeedBlitzGameState();
}

class _SpeedBlitzGameState extends State<SpeedBlitzGame> {
  int _secondsRemaining = 45;
  Timer? _timer;
  int _score = 0;
  int _combo = 0;
  int _currentQuestionIndex = 0;

  final List<BlitzQuestion> _questions = const [
    BlitzQuestion(
      prompt: 'Quick! What is the natural opposite of "Cheap"?',
      category: 'VOCABULARY REFLEX',
      options: ['Expensive', 'Costly', 'Understated', 'Reasonable'],
      correctIndex: 0,
      spokenModelAnswer: 'Expensive',
    ),
    BlitzQuestion(
      prompt: 'Say in spoken English: "La cuenta, por favor"',
      category: 'RESTAURANT SURVIVAL',
      options: ['The menu, please', 'The check, please', 'The recipe, please', 'The food, please'],
      correctIndex: 1,
      spokenModelAnswer: 'The check, please',
    ),
    BlitzQuestion(
      prompt: 'Natural spoken reduction: "I am going to leave"',
      category: 'CONNECTED SPEECH',
      options: ['I gotta leave', 'I wanna leave', 'I\'m gonna leave', 'I should leave'],
      correctIndex: 2,
      spokenModelAnswer: 'I\'m gonna leave',
    ),
    BlitzQuestion(
      prompt: 'Polite barista order: "Could I ___ a latte?"',
      category: 'DAILY DRILL',
      options: ['get', 'make', 'give', 'want'],
      correctIndex: 0,
      spokenModelAnswer: 'get',
    ),
    BlitzQuestion(
      prompt: 'How to ask if Wi-Fi is complimentary?',
      category: 'HOTEL & TRAVEL',
      options: ['Is Wi-Fi free of charge?', 'Does Wi-Fi pay?', 'How much to Wi-Fi?', 'Can Wi-Fi work?'],
      correctIndex: 0,
      spokenModelAnswer: 'Is Wi-Fi free of charge?',
    ),
    BlitzQuestion(
      prompt: 'Emergency: "My flight has been ___"',
      category: 'AIRPORT BLITZ',
      options: ['delayed', 'delayed-ed', 'delays', 'delaying'],
      correctIndex: 0,
      spokenModelAnswer: 'delayed',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          if (_score >= 300) {
            widget.onVictory();
          } else {
            widget.onDefeat();
          }
        }
      });
    });
  }

  void _handleSelect(int index) {
    final q = _questions[_currentQuestionIndex];
    if (index == q.correctIndex) {
      VocaHaptics.success();
      _combo++;
      _score += 100 + (_combo * 30);
    } else {
      VocaHaptics.error();
      _combo = 0;
      _secondsRemaining = (_secondsRemaining - 3).clamp(0, 60); // Time penalty!
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _timer?.cancel();
      widget.onVictory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Top Bar with Countdown Ring
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BouncyTap(
                    onTap: widget.onDefeat,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                    ),
                  ),

                  // Timer Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _secondsRemaining < 10
                          ? const Color(0xFFE11D48).withOpacity(0.25)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _secondsRemaining < 10 ? const Color(0xFFE11D48) : const Color(0xFF334155),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 16,
                          color: _secondsRemaining < 10 ? const Color(0xFFE11D48) : const Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_secondsRemaining}s REMAINING',
                          style: TextStyle(
                            color: _secondsRemaining < 10 ? const Color(0xFFE11D48) : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Score
                  Text(
                    '$_score PTS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Combo Multiplier Banner
              if (_combo > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD97706), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 6),
                      Text(
                        '${_combo}x BLITZ STREAK ACTIVE!',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Prompt Question Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF334155), width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      q.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF818CF8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      q.prompt,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4 Fast Blitz Options
              Expanded(
                child: ListView.separated(
                  itemCount: q.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return BouncyTap(
                      onTap: () => _handleSelect(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              q.options[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
