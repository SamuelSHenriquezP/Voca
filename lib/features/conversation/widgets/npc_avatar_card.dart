import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';

class NpcAvatarCard extends StatelessWidget {
  final String name;
  final String role;
  final String avatarEmoji;
  final bool isSpeaking;
  final String statusText; // 'Listening...', 'Speaking...', 'Evaluating...'

  const NpcAvatarCard({
    super.key,
    this.name = 'Agent Miller',
    this.role = 'Airport Customs Officer',
    this.avatarEmoji = '👮‍♂️',
    this.isSpeaking = false,
    this.statusText = 'Listening...',
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (statusText.contains('Speaking')) {
      statusColor = VocaColors.accentPink;
    } else if (statusText.contains('Listening')) {
      statusColor = VocaColors.electricCyan;
    } else {
      statusColor = VocaColors.goldXp;
    }

    return Column(
      children: [
        // Concentric Ripple Rings & Avatar
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ripple Ring
              if (isSpeaking)
                Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: VocaColors.electricCyan.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.15, 1.15),
                      duration: const Duration(milliseconds: 1100),
                    ),

              // Middle Ripple Ring
              if (isSpeaking)
                Container(
                  width: 114,
                  height: 114,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VocaColors.electricCyan.withOpacity(0.12),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.08, 1.08),
                      duration: const Duration(milliseconds: 900),
                    ),

              // Core Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2C3E50),
                      Color(0xFF4CA1AF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    avatarEmoji,
                    style: const TextStyle(fontSize: 44),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Name & Role
        Text(
          name,
          style: VocaTypography.heading2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          role,
          style: VocaTypography.caption.copyWith(
            color: Colors.white70,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),

        // Animated Status Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.6), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.3, 1.3),
                    duration: const Duration(milliseconds: 600),
                  ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: VocaTypography.caption.copyWith(
                  color: Colors.white,
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

