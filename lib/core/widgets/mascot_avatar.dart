import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/voca_colors.dart';

class MascotAvatar extends StatelessWidget {
  final double size;
  final bool isAnimated;
  final String emotion; // 'happy', 'excited', 'thinking', 'proud'

  const MascotAvatar({
    super.key,
    this.size = 56.0,
    this.isAnimated = true,
    this.emotion = 'happy',
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB142),
            Color(0xFFFF5252),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: VocaColors.rubyRedShadow.withOpacity(0.35),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Text(
          emotion == 'excited'
              ? '🤩'
              : emotion == 'thinking'
                  ? '🧐'
                  : emotion == 'proud'
                      ? '😎'
                      : '🦊',
          style: TextStyle(fontSize: size * 0.52),
        ),
      ),
    );

    if (isAnimated) {
      return avatar
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -6,
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeInOutSine,
          );
    }

    return avatar;
  }
}

