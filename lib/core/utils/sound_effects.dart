import 'haptic_feedback_utils.dart';

/// Sound and event effects trigger utility
class SoundEffects {
  SoundEffects._();

  static void playTap() {
    HapticUtils.light();
  }

  static void playSuccess() {
    HapticUtils.medium();
  }

  static void playError() {
    HapticUtils.error();
  }

  static void playCelebration() {
    HapticUtils.heavy();
  }
}

