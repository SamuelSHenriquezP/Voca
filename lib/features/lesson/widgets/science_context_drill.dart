import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/exercise.dart';

class ScienceContextDrill extends StatefulWidget {
  final ExerciseModel exercise;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;
  final Set<String>? disabledOptions;

  const ScienceContextDrill({
    super.key,
    required this.exercise,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.disabledOptions,
  });

  @override
  State<ScienceContextDrill> createState() => _ScienceContextDrillState();
}

class _ScienceContextDrillState extends State<ScienceContextDrill> {
  late FlutterTts _tts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.46);
    _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speakSnippet() async {
    if (_isSpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      final text = widget.exercise.factSnippet.isNotEmpty
          ? widget.exercise.factSnippet
          : widget.exercise.prompt;
      setState(() => _isSpeaking = true);
      await _tts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final options = ex.scienceOptions;
    final badge = ex.factBadge.isNotEmpty ? ex.factBadge : '🔬 CIENCIA Y CURIOSIDAD';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Science Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.science_rounded, size: 14, color: Color(0xFF16A34A)),
                const SizedBox(width: 5),
                Text(
                  badge.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Main Prompt
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

          // Real-World Science Fact Card
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HECHO CIENTÍFICO EN INGLÉS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D9488),
                        letterSpacing: 0.8,
                      ),
                    ),
                    BouncyTap(
                      onTap: () {
                        VocaHaptics.selection();
                        _speakSnippet();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _isSpeaking ? const Color(0xFFCCFBF1) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isSpeaking ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                              size: 16,
                              color: _isSpeaking ? const Color(0xFF0F766E) : const Color(0xFF475569),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isSpeaking ? 'Escuchando' : 'Escuchar',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _isSpeaking ? const Color(0xFF0F766E) : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Scientific snippet paragraph
                Text(
                  ex.factSnippet,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Fact Question / Challenge
          if (ex.factQuestion.isNotEmpty) ...[
            Text(
              ex.factQuestion,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Options
          ...options.map((opt) {
            final isSelected = widget.selectedAnswer == opt;
            final isDisabled = widget.disabledOptions?.contains(opt) ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Opacity(
                opacity: isDisabled ? 0.35 : 1.0,
                child: BouncyTap(
                  onTap: isDisabled
                      ? null
                      : () {
                          VocaHaptics.selection();
                          widget.onAnswerSelected(opt);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2.0 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF16A34A).withOpacity(0.12)
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
                            color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
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
                            opt,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF15803D) : const Color(0xFF1E293B),
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

