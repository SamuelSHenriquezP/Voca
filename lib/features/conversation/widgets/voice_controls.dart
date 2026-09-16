import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';

class VoiceControls extends StatefulWidget {
  final bool isSpeaking;
  final bool isRecording;
  final VoidCallback onToggleRecording;
  final VoidCallback onHint;
  final VoidCallback onSurrender;
  final Function(String text)? onSendText;

  const VoiceControls({
    super.key,
    required this.isSpeaking,
    required this.isRecording,
    required this.onToggleRecording,
    required this.onHint,
    required this.onSurrender,
    this.onSendText,
  });

  @override
  State<VoiceControls> createState() => _VoiceControlsState();
}

class _VoiceControlsState extends State<VoiceControls> {
  bool _isKeyboardMode = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitText() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && widget.onSendText != null) {
      widget.onSendText!(text);
      _textController.clear();
      HapticUtils.selection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: VocaColors.borderLight, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _isKeyboardMode ? _buildKeyboardMode() : _buildVoiceMode(),
      ),
    );
  }

  Widget _buildKeyboardMode() {
    return Row(
      children: [
        BouncyTap(
          onTap: () {
            HapticUtils.selection();
            setState(() => _isKeyboardMode = false);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
            ),
            child: const Icon(Icons.mic_rounded, color: Color(0xFF4F46E5), size: 22),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: TextField(
              controller: _textController,
              onSubmitted: (_) => _submitText(),
              decoration: const InputDecoration(
                hintText: 'Type any phrase in English...',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        BouncyTap(
          onTap: _submitText,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF4F46E5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Keyboard Mode Toggle
        BouncyTap(
          onTap: () {
            HapticUtils.selection();
            setState(() => _isKeyboardMode = true);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
                ),
                child: const Icon(
                  Icons.keyboard_rounded,
                  color: Color(0xFF4F46E5),
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Type',
                style: VocaTypography.caption.copyWith(
                  color: VocaColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Hint Button
        BouncyTap(
          onTap: widget.onHint,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: VocaColors.goldTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: VocaColors.goldXp, width: 1.5),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFFB07200),
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hint',
                style: VocaTypography.caption.copyWith(
                  color: VocaColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Main Glowing Pushable Microphone Button
        GestureDetector(
          onTap: () {
            HapticUtils.medium();
            widget.onToggleRecording();
          },
          child: SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Aura
                if (widget.isRecording)
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VocaColors.accentPink.withOpacity(0.25),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.3, 1.3),
                        duration: const Duration(milliseconds: 650),
                      ),

                // Shadow Base
                Positioned(
                  top: 4,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isRecording
                          ? VocaColors.accentPinkShadow
                          : VocaColors.primaryPurpleShadow,
                    ),
                  ),
                ),

                // Surface
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isRecording ? VocaColors.accentPink : VocaColors.primaryPurple,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isRecording ? VocaColors.accentPink : VocaColors.primaryPurple)
                            .withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Surrender Button
        BouncyTap(
          onTap: widget.onSurrender,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: VocaColors.redTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: VocaColors.rubyRed.withOpacity(0.5), width: 1.5),
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: VocaColors.rubyRed,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Exit',
                style: VocaTypography.caption.copyWith(
                  color: VocaColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

