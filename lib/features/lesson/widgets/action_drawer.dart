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
    this.encouragement = 'High precision pronunciation match.',
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
            text: 'CHECK ANSWER',
            variant: isCheckEnabled ? VocaButtonVariant.primary : VocaButtonVariant.neutral,
            isFullWidth: true,
            height: 48,
            onPressed: isCheckEnabled ? onCheck : null,
          ),
        ),
      );
    }

    if (state == DrawerState.success) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFF10B981), width: 2.0),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Color(0xFF059669), size: 20),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.65, 0.65),
                        end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correct',
                          style: VocaTypography.heading2.copyWith(
                            color: const Color(0xFF059669),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          encouragement,
                          style: VocaTypography.bodySmall.copyWith(
                            color: const Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              VocaButton(
                text: 'CONTINUE',
                variant: VocaButtonVariant.success,
                isFullWidth: true,
                height: 48,
                onPressed: onContinue,
              ),
            ],
          ),
        ),
      ).animate().slideY(
            begin: 0.5,
            end: 0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
          );
    }

    // DrawerState.error
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFDC2626), width: 2.0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Color(0xFFDC2626), size: 20),
                )
                    .animate()
                    .shake(hz: 4, curve: Curves.easeInOutCubic, duration: const Duration(milliseconds: 350)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incorrect',
                        style: VocaTypography.heading2.copyWith(
                          color: const Color(0xFFDC2626),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (correctAnswer.isNotEmpty)
                        Text(
                          'Expected: $correctAnswer',
                          style: VocaTypography.bodySmall.copyWith(
                            color: const Color(0xFF991B1B),
                            fontWeight: FontWeight.w600,
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
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: VocaTypography.caption.copyWith(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            VocaButton(
              text: 'GOT IT',
              variant: VocaButtonVariant.danger,
              isFullWidth: true,
              height: 48,
              onPressed: onGotIt,
            ),
          ],
        ),
      ),
    ).animate().slideY(
          begin: 0.5,
          end: 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
  }
}
