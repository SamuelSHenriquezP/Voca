import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptic_feedback_utils.dart';
import '../utils/sound_effects.dart';
import '../../features/lesson/models/tactical_card.dart';
import 'voca_avatar.dart';
import '../storage/local_storage_service.dart';
import 'voca_button.dart';

class CelebrationDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final int xpEarned;
  final int accuracyPercent;
  final int streakDays;
  final String characterId;
  final VoidCallback onContinue;

  const CelebrationDialog({
    super.key,
    this.title = 'LESSON COMPLETE!',
    this.subtitle = 'Speech muscle memory strengthened',
    this.xpEarned = 35,
    this.accuracyPercent = 94,
    this.streakDays = 1,
    this.characterId = 'alex',
    required this.onContinue,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'LESSON COMPLETE!',
    String subtitle = 'Speech muscle memory strengthened',
    int xpEarned = 35,
    int accuracyPercent = 94,
    int streakDays = 1,
    String characterId = 'alex',
    required VoidCallback onContinue,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) => CelebrationDialog(
        title: title,
        subtitle: subtitle,
        xpEarned: xpEarned,
        accuracyPercent: accuracyPercent,
        streakDays: streakDays,
        characterId: characterId,
        onContinue: onContinue,
      ),
    );
  }

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animController;
  late Animation<double> _xpAnimation;

  late final List<TacticalCard> _draftCards;
  TacticalCard? _selectedCard;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();

    final pool = List<TacticalCard>.from(TacticalCard.all)..shuffle();
    _draftCards = pool.take(3).toList();
    _selectedCard = _draftCards.first;

    SoundEffects.playCelebration();
    VocaHaptics.success();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _xpAnimation = Tween<double>(begin: 0, end: widget.xpEarned.toDouble()).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti Blast Cannons
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Color(0xFF6366F1),
              Color(0xFF10B981),
              Color(0xFFF59E0B),
              Color(0xFFEC4899),
              Color(0xFF06B6D4),
            ],
            numberOfParticles: 35,
            gravity: 0.25,
          ),
        ),

        // Modal Content
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: const Offset(0, 12),
                  blurRadius: 36,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Celebrating VOCA Avatar Mascot
                  Builder(
                    builder: (context) {
                      final storage = LocalStorageService();
                      return VocaAvatar(
                        head: storage.getVocaHead(),
                        hair: storage.getVocaHair(),
                        eyes: storage.getVocaEyes(),
                        mouth: storage.getVocaMouth(),
                        outfit: storage.getVocaOutfit(),
                        backdrop: storage.getVocaBackdrop(),
                        size: 96,
                      );
                    },
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Rewards Stat Cards Row
                  Row(
                    children: [
                      // XP Gained Card (with rolling counter)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.bolt_rounded, color: Color(0xFF4F46E5), size: 24),
                              const SizedBox(height: 4),
                              AnimatedBuilder(
                                animation: _xpAnimation,
                                builder: (context, _) {
                                  return Text(
                                    '+${_xpAnimation.value.toInt()} XP',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF4F46E5),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'EXPERIENCE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6366F1),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Accuracy Meter Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 24),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.accuracyPercent}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'ACCURACY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF16A34A),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Roguelike Reward Card Selection Draft
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 15, color: Color(0xFF4F46E5)),
                            SizedBox(width: 6),
                            Text(
                              'ELIGE TU CARTA DE APOYO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4F46E5),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: _draftCards.map((card) {
                            final isSelected = _selectedCard?.type == card.type;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  VocaHaptics.selection();
                                  setState(() => _selectedCard = card);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? card.lightBg : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? card.primaryColor : const Color(0xFFCBD5E1),
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: card.primaryColor.withOpacity(0.18),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(card.icon, size: 20, color: card.primaryColor),
                                      const SizedBox(height: 4),
                                      Text(
                                        card.shortName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? card.primaryColor : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '+1 CARTA',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: card.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Clean Flat Action Button
                  VocaButton(
                    text: _selectedCard != null ? 'RECLAMAR Y CONTINUAR' : 'CONTINUAR',
                    variant: VocaButtonVariant.success,
                    height: 52,
                    isFullWidth: true,
                    onPressed: () {
                      if (_selectedCard != null) {
                        TacticalCard.add(_selectedCard!.type, 1);
                      }
                      Navigator.of(context).pop();
                      widget.onContinue();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
