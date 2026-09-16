import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';

class MinimalPairItem {
  final String wordA;
  final String ipaA;
  final String wordB;
  final String ipaB;
  final int correctOption; // 0 for A, 1 for B
  final String phonemeFocus;
  final String contextualDifference;

  const MinimalPairItem({
    required this.wordA,
    required this.ipaA,
    required this.wordB,
    required this.ipaB,
    required this.correctOption,
    required this.phonemeFocus,
    required this.contextualDifference,
  });
}

class MinimalPairDuelGame extends StatefulWidget {
  final VoidCallback onVictory;
  final VoidCallback onDefeat;

  const MinimalPairDuelGame({
    super.key,
    required this.onVictory,
    required this.onDefeat,
  });

  @override
  State<MinimalPairDuelGame> createState() => _MinimalPairDuelGameState();
}

class _MinimalPairDuelGameState extends State<MinimalPairDuelGame>
    with SingleTickerProviderStateMixin {
  int _currentRound = 0;
  int _score = 0;
  int _combo = 0;
  int _lives = 3;
  double _timeProgress = 1.0;
  Timer? _countdownTimer;
  late AnimationController _waveController;

  final List<MinimalPairItem> _rounds = const [
    MinimalPairItem(
      wordA: 'Sheep',
      ipaA: '/ʃiːp/',
      wordB: 'Ship',
      ipaB: '/ʃɪp/',
      correctOption: 1, // Target is "Ship"
      phonemeFocus: '/iː/ (larga) vs /ɪ/ (corta relajada)',
      contextualDifference: '"Ship" es una embarcación; "Sheep" es el animal ovino.',
    ),
    MinimalPairItem(
      wordA: 'Very',
      ipaA: '/ˈver.i/',
      wordB: 'Berry',
      ipaB: '/ˈber.i/',
      correctOption: 0, // Target is "Very"
      phonemeFocus: 'Fricativa labiodental /v/ vs oclusiva bilabial /b/',
      contextualDifference: 'Muerde ligeramente el labio inferior para la /v/ de "Very".',
    ),
    MinimalPairItem(
      wordA: 'Think',
      ipaA: '/θɪŋk/',
      wordB: 'Sink',
      ipaB: '/sɪŋk/',
      correctOption: 0, // Target is "Think"
      phonemeFocus: 'Fricativa interdental sorda /θ/ vs alveolar /s/',
      contextualDifference: 'Coloca la punta de la lengua entre los dientes para "Think".',
    ),
    MinimalPairItem(
      wordA: 'Cat',
      ipaA: '/kæt/',
      wordB: 'Cut',
      ipaB: '/kʌt/',
      correctOption: 1, // Target is "Cut"
      phonemeFocus: 'Vocal abierta anterior /æ/ vs vocal central /ʌ/',
      contextualDifference: '"Cut" se articula con la mandíbula relajada y garganta neutra.',
    ),
    MinimalPairItem(
      wordA: 'Beach',
      ipaA: '/biːtʃ/',
      wordB: 'Bitch',
      ipaB: '/bɪtʃ/',
      correctOption: 0, // Target is "Beach"
      phonemeFocus: 'Tensa /iː/ vs laxa /ɪ/',
      contextualDifference: '"Beach" (playa) requiere sonreír alargando la vocal /iː/.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _startRoundTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _startRoundTimer() {
    _countdownTimer?.cancel();
    _timeProgress = 1.0;
    const interval = Duration(milliseconds: 50);
    const totalMs = 4500.0; // 4.5 seconds per duel

    _countdownTimer = Timer.periodic(interval, (timer) {
      if (!mounted) return;
      setState(() {
        _timeProgress -= (interval.inMilliseconds / totalMs);
        if (_timeProgress <= 0.0) {
          _timeProgress = 0.0;
          timer.cancel();
          _handleAnswer(-1); // Timeout penalty
        }
      });
    });
  }

  void _handleAnswer(int selectedOption) {
    _countdownTimer?.cancel();
    final round = _rounds[_currentRound];
    final isCorrect = selectedOption == round.correctOption;

    if (isCorrect) {
      VocaHaptics.success();
      _combo++;
      _score += 100 + (_combo * 25);
    } else {
      VocaHaptics.error();
      _combo = 0;
      _lives--;
    }

    if (_lives <= 0) {
      widget.onDefeat();
      return;
    }

    if (_currentRound < _rounds.length - 1) {
      setState(() {
        _currentRound++;
      });
      _startRoundTimer();
    } else {
      widget.onVictory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _rounds[_currentRound];
    final targetWord = currentItem.correctOption == 0 ? currentItem.wordA : currentItem.wordB;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Obsidian Roguelike
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Top HUD
              _buildTopHud(),

              const SizedBox(height: 12),

              // Time Attack Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _timeProgress,
                  minHeight: 5,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeProgress > 0.3 ? const Color(0xFF0284C7) : const Color(0xFFE11D48),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Audio Acoustic Waveform Canvas
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF334155), width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF0284C7), width: 1),
                        ),
                        child: Text(
                          currentItem.phonemeFocus.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Animated Soundwave Canvas
                      SizedBox(
                        height: 80,
                        width: double.infinity,
                        child: AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(double.infinity, 80),
                              painter: _AcousticRadarPainter(
                                progress: _waveController.value,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      BouncyTap(
                        onTap: () {
                          VocaHaptics.light();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Acoustic Stimulus: "$targetWord"'),
                              backgroundColor: const Color(0xFF1E293B),
                              duration: const Duration(milliseconds: 800),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'LISTEN TO TARGET AUDIO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text(
                        currentItem.contextualDifference,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Duel Choice Cards (Option A vs Option B)
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildChoiceCard(
                        index: 0,
                        word: currentItem.wordA,
                        ipa: currentItem.ipaA,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildChoiceCard(
                        index: 1,
                        word: currentItem.wordB,
                        ipa: currentItem.ipaB,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHud() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Lives
        Row(
          children: List.generate(3, (index) {
            final isAlive = index < _lives;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                isAlive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isAlive ? const Color(0xFFDC2626) : const Color(0xFF475569),
                size: 20,
              ),
            );
          }),
        ),

        // Round
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'ROUND ${_currentRound + 1} / ${_rounds.length}',
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),

        // Score & Combo
        Row(
          children: [
            if (_combo > 1)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_combo}x COMBO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            Text(
              '$_score PTS',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceCard({
    required int index,
    required String word,
    required String ipa,
  }) {
    return BouncyTap(
      onTap: () => _handleAnswer(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(0, 6),
              blurRadius: 14,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                ipa,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'TAP TO CHOOSE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcousticRadarPainter extends CustomPainter {
  final double progress;

  _AcousticRadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final width = size.width;

    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final wavePath = Path();
    wavePath.moveTo(0, midY);

    for (double x = 0; x <= width; x += 4) {
      final normX = x / width;
      final envelope = math.sin(normX * math.pi);
      final y = midY +
          math.sin((normX * 8 * math.pi) + (progress * 2 * math.pi)) *
              (size.height * 0.35) *
              envelope;
      wavePath.lineTo(x, y);
    }

    canvas.drawPath(wavePath, paint);
  }

  @override
  bool shouldRepaint(covariant _AcousticRadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
