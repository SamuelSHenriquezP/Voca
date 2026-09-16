import 'dart:async';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/voca_button.dart';
import '../cards/linguistic_card.dart';
import '../models/battle_state.dart';
import '../widgets/boss_canvas_painter.dart';
import '../widgets/card_widget.dart';

class CardBattleScreen extends StatefulWidget {
  final LinguisticMonster monster;
  final List<LinguisticCard> deck;
  final int playerHp;
  final int playerMaxHp;
  final int floor;

  const CardBattleScreen({
    super.key,
    required this.monster,
    required this.deck,
    required this.playerHp,
    required this.playerMaxHp,
    required this.floor,
  });

  @override
  State<CardBattleScreen> createState() => _CardBattleScreenState();
}

class _CardBattleScreenState extends State<CardBattleScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late LinguisticMonster _monster;

  late int _playerHp;
  late int _playerMaxHp;
  int _playerBlock = 0;
  int _energy = 3;
  final int _maxEnergy = 3;
  int _turn = 1;
  bool _isPlayerTurn = true;

  final List<LinguisticCard> _drawPile = [];
  final List<LinguisticCard> _hand = [];
  final List<LinguisticCard> _discardPile = [];
  final List<LinguisticCard> _runDeck = [];

  // Visual effects
  bool _shakeScreen = false;
  String? _bannerMessage;
  Color _bannerColor = const Color(0xFFE11D48);
  bool _isVictory = false;
  bool _isDefeat = false;

  // Reward Drafting
  List<LinguisticCard>? _rewardOptions;
  LinguisticCard? _selectedRewardCard;

  // Pacing Timer (3 to 4 minutes max per level)
  int _remainingSeconds = 210; // 3 min 30 sec
  Timer? _encounterTimer;

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _monster = widget.monster;
    _playerHp = widget.playerHp;
    _playerMaxHp = widget.playerMaxHp;
    _runDeck.addAll(widget.deck);

    _startTimer();
    _initCombat();
  }

  @override
  void dispose() {
    _encounterTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _encounterTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isVictory || _isDefeat) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() => _remainingSeconds--);
        }
      } else {
        timer.cancel();
        _handleTimeExpired();
      }
    });
  }

  void _handleTimeExpired() {
    if (_isVictory || _isDefeat) return;
    VocaHaptics.error();
    _showFloatingBanner('TIME EXPIRED! GUARDIAN ENRAGED', const Color(0xFFDC2626));
    setState(() {
      _playerHp = (_playerHp - 6).clamp(0, _playerMaxHp);
      if (_playerHp <= 0) {
        _isDefeat = true;
      } else {
        _remainingSeconds = 60; // 60s sudden death overtime
        _startTimer();
      }
    });
  }

  void _initCombat() {
    _drawPile.addAll(_runDeck..shuffle());
    _startPlayerTurn();
  }

  void _startPlayerTurn() {
    setState(() {
      _isPlayerTurn = true;
      _energy = _maxEnergy;
      _playerBlock = 0; // Block expires at start of turn
      _drawCards(4);
      _monster.planNextIntent(_turn);
    });
  }

  void _drawCards(int count) {
    for (int i = 0; i < count; i++) {
      if (_drawPile.isEmpty) {
        if (_discardPile.isEmpty) break;
        _drawPile.addAll(_discardPile..shuffle());
        _discardPile.clear();
      }
      if (_drawPile.isNotEmpty && _hand.length < 6) {
        _hand.add(_drawPile.removeLast());
      }
    }
  }

  void _triggerShake() {
    setState(() => _shakeScreen = true);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _shakeScreen = false);
    });
  }

  void _showFloatingBanner(String message, Color color) {
    setState(() {
      _bannerMessage = message;
      _bannerColor = color;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _bannerMessage == message) {
        setState(() => _bannerMessage = null);
      }
    });
  }

  void _playCard(LinguisticCard card) {
    if (!_isPlayerTurn || _energy < card.energyCost) return;

    VocaHaptics.medium();

    // Show rapid critical drill challenge
    _openCriticalDrillModal(card);
  }

  void _openCriticalDrillModal(LinguisticCard card) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CriticalDrillModal(
        card: card,
        onResolved: (isCritical) {
          Navigator.of(ctx).pop();
          _executeCardAction(card, isCritical);
        },
      ),
    );
  }

  void _executeCardAction(LinguisticCard card, bool isCritical) {
    setState(() {
      _energy -= card.energyCost;
      _hand.remove(card);
      _discardPile.add(card);

      final multiplier = isCritical ? 2.0 : 1.0;

      // 1. Attack
      if (card.damage > 0) {
        final totalDamage = (card.damage * multiplier).toInt();
        _monster.takeDamage(totalDamage);
        _triggerShake();
        _showFloatingBanner(
          isCritical ? 'CRITICAL STRIKE! -$totalDamage' : '-$totalDamage DMG',
          const Color(0xFFE11D48),
        );
      }

      // 2. Defense
      if (card.block > 0) {
        final totalBlock = isCritical ? (card.block + 6) : card.block;
        _playerBlock += totalBlock;
        _showFloatingBanner('+$totalBlock BLOCK', const Color(0xFF0284C7));
      }

      // 3. Skill specifics
      if (card.type == CardType.skill) {
        if (card.id == 'card_skill_1' || card.id == 'card_devil_advocate') {
          _drawCards(2);
        } else if (card.id == 'card_catch_up') {
          _energy = (_energy + 1).clamp(0, _maxEnergy + 1);
          _drawCards(1);
        }
      }

      // Check Monster Death
      if (_monster.isDead) {
        _handleVictory();
      }
    });
  }

  void _handleVictory() {
    _isVictory = true;
    _confettiController.play();
    VocaHaptics.success();
    _rewardOptions = DeckCatalog.getRandomRewards(3);
  }

  void _endPlayerTurn() async {
    if (!_isPlayerTurn || _isVictory || _isDefeat) return;

    VocaHaptics.light();

    setState(() {
      _isPlayerTurn = false;
      // Discard remaining hand
      _discardPile.addAll(_hand);
      _hand.clear();
    });

    // Enemy Turn Delay for realistic dramatic pacing
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      final intent = _monster.currentIntent;

      if (intent.type == MonsterIntentType.attack) {
        final incomingDmg = intent.value;
        if (_playerBlock >= incomingDmg) {
          _playerBlock -= incomingDmg;
          _showFloatingBanner('BLOCKED -$incomingDmg', const Color(0xFF0284C7));
        } else {
          final unblocked = incomingDmg - _playerBlock;
          _playerBlock = 0;
          _playerHp = (_playerHp - unblocked).clamp(0, _playerMaxHp);
          _triggerShake();
          VocaHaptics.error();
          _showFloatingBanner('HIT -$unblocked HP', const Color(0xFFDC2626));
        }
      } else if (intent.type == MonsterIntentType.defend) {
        _monster.gainBlock(intent.value);
        _showFloatingBanner('+${intent.value} ENEMY SHIELD', const Color(0xFF0284C7));
      }

      // Check Player Defeat
      if (_playerHp <= 0) {
        _isDefeat = true;
        VocaHaptics.error();
        return;
      }

      // Advance to next turn
      _turn++;
      _startPlayerTurn();
    });
  }

  void _finishCombatAndExit() {
    if (_selectedRewardCard != null) {
      _runDeck.add(_selectedRewardCard!);
    }
    Navigator.of(context).pop({
      'playerHp': _playerHp,
      'runDeck': _runDeck,
      'isVictory': _isVictory,
      'xpEarned': _monster.isBoss ? 500 : (_monster.isElite ? 250 : 120),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Dark Obsidian Arena
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              transform: _shakeScreen
                  ? (Matrix4.identity()
                    ..translate((math.Random().nextDouble() - 0.5) * 16,
                        (math.Random().nextDouble() - 0.5) * 16))
                  : Matrix4.identity(),
              child: Column(
                children: [
                  // 1. Top HUD: Floor, Turn, Status
                  _buildTopHud(),

                  // 2. Boss Arena (Canvas Avatar, Intent, HP & Block)
                  Expanded(
                    flex: 5,
                    child: _buildMonsterArena(),
                  ),

                  // 3. Player Status (HP, Block, Energy)
                  _buildPlayerStatusRow(),

                  // 4. Player Hand & Turn Controls
                  Expanded(
                    flex: 6,
                    child: _buildPlayerHand(),
                  ),
                ],
              ),
            ),

            // Confetti for Victory
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [
                  Color(0xFFF59E0B),
                  Color(0xFF0284C7),
                  Color(0xFF10B981),
                  Color(0xFF8B5CF6)
                ],
              ),
            ),

            // Floating Combat Banner
            if (_bannerMessage != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _bannerColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _bannerColor.withOpacity(0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Text(
                    _bannerMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

            // Victory Modal Overlay
            if (_isVictory) _buildVictoryOverlay(),

            // Defeat Modal Overlay
            if (_isDefeat) _buildDefeatOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers_rounded, color: Color(0xFF38BDF8), size: 16),
                const SizedBox(width: 6),
                Text(
                  'FLOOR ${widget.floor} - TURN $_turn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _remainingSeconds < 45
                  ? const Color(0xFFEF4444).withOpacity(0.2)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _remainingSeconds < 45
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF38BDF8).withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: _remainingSeconds < 45
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF38BDF8),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _formattedTime,
                  style: TextStyle(
                    color: _remainingSeconds < 45 ? const Color(0xFFEF4444) : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildMonsterArena() {
    final intent = _monster.currentIntent;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Monster Intent Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: intent.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: intent.color.withOpacity(0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(intent.icon, color: intent.color, size: 16),
                const SizedBox(width: 6),
                Text(
                  'INTENT: ${intent.name} (${intent.value})',
                  style: TextStyle(
                    color: intent.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Custom Vector Canvas Monster
          BossCanvasWidget(
            avatarId: _monster.avatarPainterId,
            size: 160,
            isAttacking: !_isPlayerTurn,
            isTakingDamage: _shakeScreen,
            isDefeated: _monster.isDead,
          ),

          const SizedBox(height: 10),

          // Monster Title & Name
          Text(
            _monster.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            _monster.title,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Monster Health & Shield Bar
          SizedBox(
            width: 220,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HP: ${_monster.hp} / ${_monster.maxHp}',
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_monster.block > 0)
                      Text(
                        'GUARD: ${_monster.block}',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_monster.hp / _monster.maxHp).clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFEF4444)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStatusRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player Health & Block
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$_playerHp / $_playerMaxHp',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_playerBlock > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: Color(0xFF38BDF8), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$_playerBlock',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // Energy & End Turn
          Row(
            children: [
              // Energy Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_energy / $_maxEnergy',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // End Turn Button
              BouncyTap(
                onTap: _isPlayerTurn ? _endPlayerTurn : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _isPlayerTurn ? const Color(0xFF1E293B) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isPlayerTurn ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                    ),
                  ),
                  child: Text(
                    _isPlayerTurn ? 'END TURN' : 'ENEMY TURN...',
                    style: TextStyle(
                      color: _isPlayerTurn ? Colors.white : const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerHand() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HAND (${_hand.length}) - DRAW PILE (${_drawPile.length})',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'DISCARD (${_discardPile.length})',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Horizontal scrollable card hand
          Expanded(
            child: _hand.isEmpty
                ? const Center(
                    child: Text(
                      'No cards in hand',
                      style: TextStyle(color: Color(0xFF475569)),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _hand.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final card = _hand[index];
                      final isPlayable = _isPlayerTurn && _energy >= card.energyCost;

                      return Center(
                        child: CardWidget(
                          card: card,
                          isPlayable: isPlayable,
                          onTap: () => _playCard(card),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 48),
            const SizedBox(height: 12),
            const Text(
              'ENCOUNTER CLEARED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Draft 1 linguistic card into your expedition deck:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // Draft Options
            if (_rewardOptions != null)
              SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: _rewardOptions!.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final rewardCard = _rewardOptions![idx];
                    final isChosen = _selectedRewardCard == rewardCard;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedRewardCard = rewardCard);
                        VocaHaptics.selection();
                      },
                      child: CardWidget(
                        card: rewardCard,
                        isSelected: isChosen,
                        width: 140,
                        height: 200,
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 28),

            VocaButton(
              text: _selectedRewardCard != null
                  ? 'ADD CARD & PROCEED'
                  : 'SKIP CARD REWARD',
              variant: VocaButtonVariant.success,
              onPressed: _finishCombatAndExit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefeatOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.heart_broken_rounded, color: Color(0xFFEF4444), size: 52),
            const SizedBox(height: 16),
            const Text(
              'EXPEDITION TERMINATED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your vocal stamina depleted before the guardian. Re-calibrate your deck and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 28),
            VocaButton(
              text: 'RETURN TO ARCADE',
              variant: VocaButtonVariant.neutral,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// CRITICAL DRILL MODAL (Rapid Response)
class _CriticalDrillModal extends StatefulWidget {
  final LinguisticCard card;
  final ValueChanged<bool> onResolved;

  const _CriticalDrillModal({
    required this.card,
    required this.onResolved,
  });

  @override
  State<_CriticalDrillModal> createState() => _CriticalDrillModalState();
}

class _CriticalDrillModalState extends State<_CriticalDrillModal> {
  Timer? _timer;
  double _timeProgress = 1.0;
  int? _selectedIdx;
  bool _showTrick = false;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 3800);
    const interval = Duration(milliseconds: 40);
    final totalSteps = duration.inMilliseconds / interval.inMilliseconds;
    var currentStep = 0;

    _timer = Timer.periodic(interval, (timer) {
      currentStep++;
      if (mounted) {
        setState(() {
          _timeProgress = (1.0 - (currentStep / totalSteps)).clamp(0.0, 1.0);
        });
      }
      if (currentStep >= totalSteps) {
        timer.cancel();
        if (mounted) {
          widget.onResolved(false); // Timeout = normal hit
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _chooseOption(int index) {
    _timer?.cancel();
    setState(() {
      _selectedIdx = index;
      _showTrick = true;
    });
    final isCorrect = index == widget.card.drill.correctIndex;
    if (isCorrect) {
      VocaHaptics.heavy();
    } else {
      VocaHaptics.light();
    }

    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        widget.onResolved(isCorrect);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final drill = widget.card.drill;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _timeProgress,
                backgroundColor: const Color(0xFF1E293B),
                valueColor: AlwaysStoppedAnimation(
                  _timeProgress > 0.3 ? const Color(0xFFFBBF24) : const Color(0xFFEF4444),
                ),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: Color(0xFFFBBF24), size: 18),
                    SizedBox(width: 4),
                    Text(
                      'CRITICAL TIMING REACTION',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.card.phrase,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Question Prompt with TRICK Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    drill.prompt,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BouncyTap(
                  onTap: () {
                    setState(() => _showTrick = !_showTrick);
                    VocaHaptics.selection();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_rounded, color: Color(0xFF34D399), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'TRICK',
                          style: TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_showTrick) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF059669)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.tips_and_updates_rounded, color: Color(0xFF6EE7B7), size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        drill.explanation,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // 3 Options
            ...List.generate(drill.options.length, (idx) {
              final isChosen = _selectedIdx == idx;
              final isAnswer = idx == drill.correctIndex;

              Color bgColor = const Color(0xFF1E293B);
              Color borderColor = const Color(0xFF334155);

              if (_selectedIdx != null) {
                if (isChosen && isAnswer) {
                  bgColor = const Color(0xFF059669).withOpacity(0.3);
                  borderColor = const Color(0xFF10B981);
                } else if (isChosen && !isAnswer) {
                  bgColor = const Color(0xFFEF4444).withOpacity(0.3);
                  borderColor = const Color(0xFFEF4444);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BouncyTap(
                  onTap: _selectedIdx == null ? () => _chooseOption(idx) : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Text(
                      drill.options[idx],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
