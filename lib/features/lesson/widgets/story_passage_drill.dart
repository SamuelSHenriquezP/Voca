import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/exercise.dart';

class StoryPassageDrill extends StatefulWidget {
  final ExerciseModel exercise;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;
  final Set<String>? disabledOptions;

  const StoryPassageDrill({
    super.key,
    required this.exercise,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.disabledOptions,
  });

  @override
  State<StoryPassageDrill> createState() => _StoryPassageDrillState();
}

class _StoryPassageDrillState extends State<StoryPassageDrill> {
  late FlutterTts _tts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.44);
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

  Future<void> _narrateStory() async {
    if (_isSpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      final ex = widget.exercise;
      final fullText = '${ex.storyPassageLeading} ${widget.selectedAnswer ?? ex.correctStoryAnswer} ${ex.storyPassageTrailing}';
      setState(() => _isSpeaking = true);
      await _tts.speak(fullText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final options = ex.storyOptions;
    final chapter = ex.storyChapterTitle.isNotEmpty
        ? ex.storyChapterTitle
        : 'Crónica del Reino de Ooo';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lore Chapter Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_stories_rounded, size: 14, color: Color(0xFFB45309)),
                    SizedBox(width: 5),
                    Text(
                      'HISTORIA Y LECTURA INMERSIVA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              BouncyTap(
                onTap: () {
                  VocaHaptics.selection();
                  _narrateStory();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isSpeaking ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isSpeaking ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSpeaking ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                        size: 15,
                        color: _isSpeaking ? const Color(0xFFB45309) : const Color(0xFF475569),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isSpeaking ? 'Narrando...' : 'Narrar relato',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _isSpeaking ? const Color(0xFFB45309) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

          // Lore Story Parchment Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2D9CE), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE2D9CE).withOpacity(0.35),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chapter Header
                Row(
                  children: [
                    const Icon(Icons.bookmark_rounded, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        chapter.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB45309),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18, color: Color(0xFFF1EAE0)),

                // Interactive Story Passage with Inline Gap
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(text: ex.storyPassageLeading),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.selectedAnswer != null
                                ? const Color(0xFFEEF2FF)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.selectedAnswer != null
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFFF59E0B),
                              width: 1.8,
                            ),
                          ),
                          child: Text(
                            widget.selectedAnswer ?? '  ?  ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: widget.selectedAnswer != null
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(text: ex.storyPassageTrailing),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Elige la palabra que completa la historia con sentido:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          // Options List
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
                            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
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
                              color: isSelected ? const Color(0xFF3730A3) : const Color(0xFF1E293B),
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

