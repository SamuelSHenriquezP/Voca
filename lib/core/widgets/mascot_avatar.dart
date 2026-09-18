import 'package:flutter/material.dart';
import 'voca_avatar.dart';

/// Mascot avatar for VOCA coaching, onboarding, and feedback
class MascotAvatar extends StatelessWidget {
  final double size;
  final bool isAnimated;
  final String emotion;

  const MascotAvatar({
    super.key,
    this.size = 52.0,
    this.isAnimated = true,
    this.emotion = 'happy',
  });

  @override
  Widget build(BuildContext context) {
    return VocaAvatar.fromId(
      'alex',
      size: size,
      isAnimated: isAnimated,
    );
  }
}
