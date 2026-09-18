import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/voca_button.dart';
import '../models/linguistic_relic.dart';

class RelicDraftDialog extends StatefulWidget {
  final List<LinguisticRelic> options;
  final Function(LinguisticRelic selectedRelic) onSelected;

  const RelicDraftDialog({
    super.key,
    required this.options,
    required this.onSelected,
  });

  static Future<LinguisticRelic?> show(
    BuildContext context, {
    required List<LinguisticRelic> options,
  }) {
    return showDialog<LinguisticRelic>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) => RelicDraftDialog(
        options: options,
        onSelected: (relic) => Navigator.of(context).pop(relic),
      ),
    );
  }

  @override
  State<RelicDraftDialog> createState() => _RelicDraftDialogState();
}

class _RelicDraftDialogState extends State<RelicDraftDialog> {
  LinguisticRelic? _selected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAF9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RELIC DRAFT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Select 1 permanent expedition enhancement',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 3 Relic Options
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.options.map((relic) {
                    final isChosen = _selected?.id == relic.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BouncyTap(
                        onTap: () {
                          VocaHaptics.selection();
                          setState(() => _selected = relic);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isChosen ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isChosen ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                              width: isChosen ? 2.0 : 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isChosen
                                      ? Colors.white.withOpacity(0.15)
                                      : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  relic.icon,
                                  size: 22,
                                  color: isChosen ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          relic.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: isChosen ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          relic.rarityLabel,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                            color: isChosen
                                                ? Colors.white70
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      relic.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isChosen
                                            ? Colors.white.withOpacity(0.9)
                                            : const Color(0xFF334155),
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '“${relic.flavorLore}”',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: isChosen
                                            ? Colors.white60
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: VocaButton(
                text: _selected == null ? 'CHOOSE AN ARTIFACT' : 'EQUIP ${_selected!.name.toUpperCase()}',
                variant: VocaButtonVariant.primary,
                height: 48,
                onPressed: _selected == null
                    ? null
                    : () {
                        VocaHaptics.heavy();
                        widget.onSelected(_selected!);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
