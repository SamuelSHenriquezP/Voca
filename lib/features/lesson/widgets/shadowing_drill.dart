import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/audio_tts_service.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/waveform_widget.dart';
import '../models/exercise.dart';

class ShadowingDrill extends StatefulWidget {
  final ExerciseModel exercise;
  final Function(bool isRecorded) onRecordingComplete;

  const ShadowingDrill({
    super.key,
    required this.exercise,
    required this.onRecordingComplete,
  });

  @override
  State<ShadowingDrill> createState() => _ShadowingDrillState();
}

class _ShadowingDrillState extends State<ShadowingDrill> {
  bool _isRecording = false;
  bool _hasRecorded = false;

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        _hasRecorded = true;
        HapticUtils.medium();
        widget.onRecordingComplete(true);
      } else {
        HapticUtils.light();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt
        Text(
          widget.exercise.prompt,
          style: VocaTypography.heading1.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          'Speak clearly into your microphone after listening',
          style: VocaTypography.bodyMedium.copyWith(color: VocaColors.textMuted),
        ),
        const SizedBox(height: 24),

        // Target Sentence Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: VocaColors.borderLight, width: 2),
            boxShadow: const [
              BoxShadow(
                color: VocaColors.borderSubtle,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BouncyTap(
                    onTap: () {
                      VocaHaptics.light();
                      AudioTtsService().speak(widget.exercise.targetSpeechText);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: VocaColors.purpleTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: VocaColors.primaryPurple,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.exercise.targetSpeechText,
                      style: VocaTypography.heading2.copyWith(
                        fontSize: 20,
                        color: VocaColors.darkSlate,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Phonetic Emphasis Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: widget.exercise.phoneticTokens.map((token) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: VocaColors.cyanTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: VocaColors.electricCyan.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      token,
                      style: VocaTypography.phonetic.copyWith(
                        color: VocaColors.electricCyanShadow,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Live Soundwave when recording
        Center(
          child: AnimatedOpacity(
            opacity: _isRecording ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const WaveformWidget(
              isSpeaking: true,
              barColor: VocaColors.accentPink,
              barCount: 22,
              maxHeight: 44,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Microphone Button with Pulsing Recording Indicator
        Center(
          child: GestureDetector(
            onTap: _toggleRecording,
            child: SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow / Pulse when recording
                  if (_isRecording)
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VocaColors.rubyRed.withOpacity(0.2),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.25, 1.25),
                          duration: const Duration(milliseconds: 700),
                        ),

                  // Shadow Base
                  Positioned(
                    top: 6,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording
                            ? VocaColors.rubyRedShadow
                            : _hasRecorded
                                ? VocaColors.emeraldGreenShadow
                                : VocaColors.primaryPurpleShadow,
                      ),
                    ),
                  ),

                  // Top Surface
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? VocaColors.rubyRed
                          : _hasRecorded
                              ? VocaColors.emeraldGreen
                              : VocaColors.primaryPurple,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
                    ),
                    child: Icon(
                      _isRecording
                          ? Icons.stop_rounded
                          : _hasRecorded
                              ? Icons.check_rounded
                              : Icons.mic_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),
        Center(
          child: Text(
            _isRecording
                ? 'Listening... Tap to stop'
                : _hasRecorded
                    ? 'Recorded! Ready to check'
                    : 'Tap microphone to speak',
            style: VocaTypography.caption.copyWith(
              color: _isRecording ? VocaColors.rubyRed : VocaColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        if (widget.exercise.expectedAccentTip.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: VocaColors.goldTint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: VocaColors.goldXp.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFB45309), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.exercise.expectedAccentTip,
                    style: VocaTypography.bodySmall.copyWith(
                      color: const Color(0xFF7A4F01),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

