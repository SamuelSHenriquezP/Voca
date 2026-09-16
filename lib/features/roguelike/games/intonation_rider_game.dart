import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';

class IntonationPrompt {
  final String sentence;
  final String patternType; // "Rising (Inquiry)", "Falling (Assertion)", "Peak & Dip"
  final String tip;
  final List<double> nativePitchPoints; // Normalized 0.0 to 1.0

  const IntonationPrompt({
    required this.sentence,
    required this.patternType,
    required this.tip,
    required this.nativePitchPoints,
  });
}

class IntonationRiderGame extends StatefulWidget {
  final VoidCallback onVictory;
  final VoidCallback onDefeat;

  const IntonationRiderGame({
    super.key,
    required this.onVictory,
    required this.onDefeat,
  });

  @override
  State<IntonationRiderGame> createState() => _IntonationRiderGameState();
}

class _IntonationRiderGameState extends State<IntonationRiderGame>
    with SingleTickerProviderStateMixin {
  int _currentPromptIndex = 0;
  bool _isRecording = false;
  int _accuracyScore = 0;
  bool _hasEvaluated = false;
  late AnimationController _riderController;

  final List<IntonationPrompt> _prompts = const [
    IntonationPrompt(
      sentence: 'Are you sure about that?',
      patternType: 'Rising Intonation (Yes/No Question)',
      tip: 'Elevate your pitch noticeably on the final syllable "that?".',
      nativePitchPoints: [0.35, 0.40, 0.42, 0.50, 0.85],
    ),
    IntonationPrompt(
      sentence: 'I will definitely be there.',
      patternType: 'Emphatic Peak & Fall',
      tip: 'Hit a sharp pitch peak on "DE-fi-nite-ly" then descend smoothly.',
      nativePitchPoints: [0.30, 0.35, 0.90, 0.55, 0.35, 0.20],
    ),
    IntonationPrompt(
      sentence: 'Could you give me a hand with this?',
      patternType: 'Polite Request Wave',
      tip: 'Gentle rise on "hand", slight dip, and gentle final lift on "this?".',
      nativePitchPoints: [0.40, 0.45, 0.50, 0.80, 0.50, 0.45, 0.65],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _riderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _riderController.dispose();
    super.dispose();
  }

  void _handleToggleRecording() {
    VocaHaptics.medium();
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        // Evaluate simulated pitch alignment
        _hasEvaluated = true;
        _accuracyScore = 88 + math.Random().nextInt(9); // 88% - 96%
        VocaHaptics.success();
      }
    });
  }

  void _handleNext() {
    if (_currentPromptIndex < _prompts.length - 1) {
      setState(() {
        _currentPromptIndex++;
        _hasEvaluated = false;
        _isRecording = false;
      });
    } else {
      widget.onVictory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _prompts[_currentPromptIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Top Bar
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4F46E5), width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.graphic_eq_rounded, color: Color(0xFF818CF8), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'INTONATION WAVE RIDER',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_currentPromptIndex + 1}/${_prompts.length}',
                      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Target Sentence Display Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155), width: 1),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        prompt.patternType.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"${prompt.sentence}"',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prompt.tip,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Pitch Contour Wave Canvas
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D16),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                  ),
                  child: Stack(
                    children: [
                      // Grid Guidelines
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _PitchGridPainter(),
                        ),
                      ),

                      // Animated Pitch Wave Curve
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _riderController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _IntonationContourPainter(
                                nativePoints: prompt.nativePitchPoints,
                                isRecording: _isRecording,
                                hasEvaluated: _hasEvaluated,
                                timeProgress: _riderController.value,
                              ),
                            );
                          },
                        ),
                      ),

                      // Legend indicators
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Row(
                          children: [
                            Container(width: 10, height: 3, color: const Color(0xFF0284C7)),
                            const SizedBox(width: 6),
                            const Text('Native Target', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                            const SizedBox(width: 14),
                            Container(width: 10, height: 3, color: const Color(0xFF10B981)),
                            const SizedBox(width: 6),
                            const Text('Your Voice Pitch', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                          ],
                        ),
                      ),

                      // Score Badge overlay
                      if (_hasEvaluated)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withOpacity(0.92),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF059669), width: 1.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_accuracyScore% PITCH ALIGNMENT',
                                  style: const TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Excellent musical cadence! Natural American flow.',
                                  style: TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Record / Next Buttons
              if (!_hasEvaluated)
                BouncyTap(
                  onTap: _handleToggleRecording,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isRecording ? const Color(0xFFE11D48) : const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isRecording ? 'STOP & EVALUATE CONTOUR' : 'SPEAK & RIDE THE WAVE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                BouncyTap(
                  onTap: _handleNext,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'CONTINUE TO NEXT WAVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PitchGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IntonationContourPainter extends CustomPainter {
  final List<double> nativePoints;
  final bool isRecording;
  final bool hasEvaluated;
  final double timeProgress;

  _IntonationContourPainter({
    required this.nativePoints,
    required this.isRecording,
    required this.hasEvaluated,
    required this.timeProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nativePoints.isEmpty) return;

    final stepX = size.width / (nativePoints.length - 1);

    // 1. Draw Native Target Curve (Blue)
    final targetPath = Path();
    for (int i = 0; i < nativePoints.length; i++) {
      final x = i * stepX;
      final y = size.height - (nativePoints[i] * (size.height - 40)) - 20;
      if (i == 0) {
        targetPath.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (nativePoints[i - 1] * (size.height - 40)) - 20;
        final cX = (prevX + x) / 2;
        targetPath.cubicTo(cX, prevY, cX, y, x, y);
      }
    }

    final targetPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(targetPath, targetPaint);

    // 2. If Evaluated or Recording, draw user's live tracked pitch (Green)
    if (isRecording || hasEvaluated) {
      final userPath = Path();
      for (int i = 0; i < nativePoints.length; i++) {
        final x = i * stepX;
        final jitter = isRecording ? (math.sin((i + timeProgress) * 4) * 0.08) : 0.02;
        final normY = (nativePoints[i] + jitter).clamp(0.1, 0.95);
        final y = size.height - (normY * (size.height - 40)) - 20;

        if (i == 0) {
          userPath.moveTo(x, y);
        } else {
          final prevX = (i - 1) * stepX;
          final prevY = size.height - (nativePoints[i - 1] * (size.height - 40)) - 20;
          final cX = (prevX + x) / 2;
          userPath.cubicTo(cX, prevY, cX, y, x, y);
        }
      }

      final userPaint = Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(userPath, userPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IntonationContourPainter oldDelegate) => true;
}
