import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/voca_button.dart';

enum DrawerState {
  standard,
  success,
  error,
}

class ActionDrawer extends StatelessWidget {
  final DrawerState state;
  final bool isCheckEnabled;
  final VoidCallback onCheck;
  final VoidCallback onContinue;
  final VoidCallback onGotIt;
  final String correctAnswer;
  final String tip;
  final String encouragement;

  const ActionDrawer({
    super.key,
    required this.state,
    required this.isCheckEnabled,
    required this.onCheck,
    required this.onContinue,
    required this.onGotIt,
    this.correctAnswer = '',
    this.tip = '',
    this.encouragement = 'Outstanding pronunciation! +10 XP',
  });

  @override
  Widget build(BuildContext context) {
    if (state == DrawerState.standard) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SafeArea(
          top: false,
          child: VocaButton(
            text: 'CHECK',
            variant: isCheckEnabled ? VocaButtonVariant.success : VocaButtonVariant.neutral,
            isFullWidth: true,
            height: 50,
            onPressed: isCheckEnabled ? onCheck : null,
          ),
        ),
      );
    }

    if (state == DrawerState.success) {
      // Duolingo Success Banner (Image 3)
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFD7FFB8), // Soft Duolingo green banner
          border: Border(
            top: BorderSide(color: Color(0xFF58CC02), width: 2.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF58CC02),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nicely done!',
                          style: TextStyle(
                            color: Color(0xFF58A700),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          encouragement,
                          style: const TextStyle(
                            color: Color(0xFF58A700),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              VocaButton(
                text: 'CONTINUE',
                variant: VocaButtonVariant.success,
                isFullWidth: true,
                height: 50,
                onPressed: onContinue,
              ),
            ],
          ),
        ),
      ).animate().slideY(
            begin: 0.8,
            end: 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
    }

    // DrawerState.error (Duolingo Red Error Banner)
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFDADC), // Duolingo soft red banner
        border: Border(
          top: BorderSide(color: Color(0xFFFF4B4B), width: 2.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4B4B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Incorrect',
                        style: TextStyle(
                          color: Color(0xFFEA2B2B),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (correctAnswer.isNotEmpty)
                        Text(
                          'Correct solution: $correctAnswer',
                          style: const TextStyle(
                            color: Color(0xFFEA2B2B),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (tip.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tip,
                        style: VocaTypography.caption.copyWith(
                          color: const Color(0xFF4B4B4B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            VocaButton(
              text: 'GOT IT',
              variant: VocaButtonVariant.danger,
              isFullWidth: true,
              height: 50,
              onPressed: onGotIt,
            ),
          ],
        ),
      ),
    ).animate().slideY(
          begin: 0.8,
          end: 0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
  }
}
