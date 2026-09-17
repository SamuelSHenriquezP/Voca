import 'package:flutter/material.dart';
import 'cartoon_character_avatar.dart';

/// Cartoon mascot avatar for VOCA path nodes, coaching, and onboarding
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
    return CartoonCharacterAvatar(
      type: CartoonCharacterType.alex,
      size: size,
      isSpeaking: emotion == 'speaking' || emotion == 'focus',
      showRipple: false,
      emotion: emotion,
    );
  }
}
