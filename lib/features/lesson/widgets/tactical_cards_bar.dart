import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/tactical_card.dart';

class TacticalCardsBar extends StatelessWidget {
  final bool isShieldActive;
  final bool isDoubleXpActive;
  final VoidCallback onUseShield;
  final VoidCallback onUseClue;
  final VoidCallback onUseSkip;
  final VoidCallback onUseDoubleXp;

  const TacticalCardsBar({
    super.key,
    required this.isShieldActive,
    required this.isDoubleXpActive,
    required this.onUseShield,
    required this.onUseClue,
    required this.onUseSkip,
    required this.onUseDoubleXp,
  });

  @override
  Widget build(BuildContext context) {
    final shieldCount = TacticalCard.getCount(TacticalCardType.shield);
    final clueCount = TacticalCard.getCount(TacticalCardType.clue);
    final skipCount = TacticalCard.getCount(TacticalCardType.skip);
    final doubleXpCount = TacticalCard.getCount(TacticalCardType.doubleXp);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildChip(
            card: TacticalCard.shieldCard,
            count: shieldCount,
            isActive: isShieldActive,
            activeLabel: 'Activo',
            onTap: onUseShield,
          ),
          _buildDivider(),
          _buildChip(
            card: TacticalCard.clueCard,
            count: clueCount,
            isActive: false,
            activeLabel: null,
            onTap: onUseClue,
          ),
          _buildDivider(),
          _buildChip(
            card: TacticalCard.skipCard,
            count: skipCount,
            isActive: false,
            activeLabel: null,
            onTap: onUseSkip,
          ),
          _buildDivider(),
          _buildChip(
            card: TacticalCard.doubleXpCard,
            count: doubleXpCount,
            isActive: isDoubleXpActive,
            activeLabel: '2x Activo',
            onTap: onUseDoubleXp,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: const Color(0xFFF1F5F9),
    );
  }

  Widget _buildChip({
    required TacticalCard card,
    required int count,
    required bool isActive,
    required String? activeLabel,
    required VoidCallback onTap,
  }) {
    final isEnabled = count > 0 || isActive;
    final primaryColor = isActive ? const Color(0xFF0D9488) : card.primaryColor;
    final bgColor = isActive
        ? const Color(0xFFCCFBF1)
        : (count > 0 ? card.lightBg : const Color(0xFFF8FAFC));
    final borderColor = isActive
        ? const Color(0xFF0D9488)
        : (count > 0 ? card.borderColor : const Color(0xFFE2E8F0));

    return BouncyTap(
      onTap: () {
        VocaHaptics.light();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isActive ? 1.5 : 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              card.icon,
              size: 16,
              color: isEnabled ? primaryColor : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 4),
            Text(
              isActive && activeLabel != null ? activeLabel : '${card.shortName} x$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isEnabled ? (isActive ? const Color(0xFF0F766E) : const Color(0xFF1E293B)) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

