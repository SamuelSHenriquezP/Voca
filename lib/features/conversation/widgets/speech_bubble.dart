import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/audio_tts_service.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/notion_avatar.dart';
import '../models/chat_message.dart';

class SpeechBubble extends StatelessWidget {
  final ChatMessage message;

  const SpeechBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: NotionAvatar.fromId(
                message.personaName ?? message.id,
                size: 34,
                isAnimated: false,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? VocaColors.darkSlate : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
                border: Border.all(
                  color: isUser ? Colors.black : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: VocaTypography.bodyMedium.copyWith(
                      color: isUser ? Colors.white : VocaColors.darkSlate,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Audio speaker button
                      BouncyTap(
                        onTap: () {
                          VocaHaptics.selection();
                          AudioTtsService().speak(message.text);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.white.withOpacity(0.18)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.volume_up_rounded,
                            size: 13,
                            color: isUser ? Colors.white : VocaColors.darkSlate,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        message.time,
                        style: VocaTypography.caption.copyWith(
                          fontSize: 10,
                          color: isUser ? Colors.white70 : VocaColors.textMuted,
                        ),
                      ),
                      if (message.accuracyScore != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${message.accuracyScore}% Match',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (message.coachGrammarTip != null || message.coachPronunciationTip != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.black.withOpacity(0.15) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isUser ? Colors.white24 : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.coachGrammarTip != null)
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 12, color: Color(0xFF10B981)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    message.coachGrammarTip!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isUser ? Colors.white.withOpacity(0.9) : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (message.coachPronunciationTip != null) ...[
                            if (message.coachGrammarTip != null) const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.record_voice_over_rounded, size: 12, color: Color(0xFF38BDF8)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    message.coachPronunciationTip!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isUser ? Colors.white.withOpacity(0.9) : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Builder(
                builder: (_) {
                  final storage = LocalStorageService();
                  return NotionAvatar(
                    head: storage.getNotionHead(),
                    hair: storage.getNotionHair(),
                    eyes: storage.getNotionEyes(),
                    mouth: storage.getNotionMouth(),
                    outfit: storage.getNotionOutfit(),
                    backdrop: storage.getNotionBackdrop(),
                    size: 34,
                    isAnimated: false,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: const Duration(milliseconds: 200))
        .slideY(
          begin: 0.1,
          end: 0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
  }
}
