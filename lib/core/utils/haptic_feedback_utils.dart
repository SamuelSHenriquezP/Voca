import 'package:flutter/services.dart';

/// Wraps haptic feedback calls for game interactions
class HapticUtils {
  HapticUtils._();

  static void light() {
    HapticFeedback.lightImpact();
  }

  static void medium() {
    HapticFeedback.mediumImpact();
  }

  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void error() {
    HapticFeedback.vibrate();
  }
}

