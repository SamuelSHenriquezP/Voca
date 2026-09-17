import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/exercise.dart';

class ListeningDrill extends StatefulWidget {
  final ExerciseModel exercise;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;
  final Set<String>? disabledOptions;

  const ListeningDrill({
    super.key,
    required this.exercise,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.disabledOptions,
  });

  @override
  State<ListeningDrill> createState() => _ListeningDrillState();
}

class _ListeningDrillState extends State<ListeningDrill> with SingleTickerProviderStateMixin {
  late FlutterTts _tts;
  bool _isPlaying = false;
  bool _isSlowSpeed = false;
  bool _showTranscript = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.48);
    _tts.setPitch(1.0);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isPlaying = false);
        _waveController.stop();
      }
    });

    _tts.setErrorHandler((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
        _waveController.stop();
      }
    });

    // Auto-play audio after slight delay
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        _playAudio();
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _playAudio() async {
    final text = widget.exercise.audioScript.isNotEmpty
        ? widget.exercise.audioScript
        : widget.exercise.prompt;

    await _tts.setSpeechRate(_isSlowSpeed ? 0.30 : 0.48);
    setState(() => _isPlaying = true);
    _waveController.repeat(reverse: true);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final options = ex.listeningOptions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge & Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.headphones_rounded, size: 14, color: Color(0xFF2563EB)),
                    SizedBox(width: 5),
                    Text(
                      'COMPRENSIÓN AUDITIVA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D4ED8),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (ex.trickTip.isNotEmpty)
                BouncyTap(
                  onTap: () {
                    setState(() => _showTranscript = !_showTranscript);
                    VocaHaptics.selection();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _showTranscript ? 'Ocultar Texto' : 'Ver Texto',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Prompt
          Text(
            ex.prompt,
            style: VocaTypography.heading2.copyWith(fontSize: 19),
          ),
          if (ex.subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              ex.subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 14),

          // Interactive Audio Player Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Big Play / Stop Button
                    BouncyTap(
                      onTap: () {
                        VocaHaptics.selection();
                        if (_isPlaying) {
                          _tts.stop();
                          setState(() => _isPlaying = false);
                          _waveController.stop();
                        } else {
                          _playAudio();
                        }
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.35),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Soundwaves indicator & status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isPlaying ? 'Reproduciendo audio nativo...' : 'Toca para escuchar el audio',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _isPlaying ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(12, (i) {
                              final height = _isPlaying
                                  ? (8 + (i % 4) * 5.0 + (_waveController.value * 8))
                                  : 6.0;
                              return Container(
                                width: 4,
                                height: height.clamp(4.0, 24.0),
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: _isPlaying
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFFCBD5E1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    // Speed Toggle Pill
                    BouncyTap(
                      onTap: () {
                        setState(() => _isSlowSpeed = !_isSlowSpeed);
                        VocaHaptics.selection();
                        _playAudio();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isSlowSpeed ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isSlowSpeed ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          _isSlowSpeed ? '🐢 0.75x' : '⚡ 1.0x',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _isSlowSpeed ? const Color(0xFFB45309) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Revealed Transcript (if toggled)
                if (_showTranscript) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      ex.audioScript,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Comprehension Question
          if (ex.comprehensionQuestion.isNotEmpty) ...[
            Text(
              ex.comprehensionQuestion,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Options List
          ...options.map((option) {
            final isSelected = widget.selectedAnswer == option;
            final isDisabled = widget.disabledOptions?.contains(option) ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Opacity(
                opacity: isDisabled ? 0.35 : 1.0,
                child: BouncyTap(
                  onTap: isDisabled
                      ? null
                      : () {
                          VocaHaptics.selection();
                          widget.onAnswerSelected(option);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2.0 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF2563EB).withOpacity(0.12)
                              : Colors.black.withOpacity(0.02),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Center(
                            child: isSelected
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

