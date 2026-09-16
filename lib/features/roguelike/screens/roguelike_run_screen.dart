import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../games/intonation_rider_game.dart';
import '../games/minimal_pair_game.dart';
import '../games/speed_blitz_game.dart';
import '../models/roguelike_run.dart';

class RoguelikeRunScreen extends StatefulWidget {
  const RoguelikeRunScreen({super.key});

  @override
  State<RoguelikeRunScreen> createState() => _RoguelikeRunScreenState();
}

class _RoguelikeRunScreenState extends State<RoguelikeRunScreen> {
  late RoguelikeRunState _run;

  final List<RoguelikeRoom> _floor1Rooms = const [
    RoguelikeRoom(
      id: 'r1_1',
      title: 'Acoustic Ear: Minimal Pair Duel',
      type: RoomType.minimalPairDuel,
      description: 'Differentiate tricky English vowels (/iː/ vs /ɪ/) under acoustic noise.',
      xpReward: 120,
    ),
    RoguelikeRoom(
      id: 'r1_2',
      title: 'Rapid Blitz: 45s Reflex Surge',
      type: RoomType.speedBlitz,
      description: 'Answer fast conversational prompts before the timer runs out.',
      xpReward: 150,
    ),
    RoguelikeRoom(
      id: 'r1_3',
      title: 'Intonation Wave: Riding Pitch Curves',
      type: RoomType.intonationWave,
      description: 'Match native vocal pitch rise and fall contours with your voice.',
      xpReward: 180,
    ),
    RoguelikeRoom(
      id: 'r1_boss',
      title: 'Floor Boss: Airport Customs Grilling',
      type: RoomType.bossBattle,
      description: 'Pass high-pressure inspection with strict officer patience limits.',
      xpReward: 350,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _run = RoguelikeRunState();
  }

  void _launchRoom(RoguelikeRoom room) {
    VocaHaptics.medium();

    Widget gameScreen;
    if (room.type == RoomType.minimalPairDuel) {
      gameScreen = MinimalPairDuelGame(
        onVictory: () => _handleRoomVictory(room),
        onDefeat: _handleRoomDefeat,
      );
    } else if (room.type == RoomType.intonationWave) {
      gameScreen = IntonationRiderGame(
        onVictory: () => _handleRoomVictory(room),
        onDefeat: _handleRoomDefeat,
      );
    } else if (room.type == RoomType.speedBlitz) {
      gameScreen = SpeedBlitzGame(
        onVictory: () => _handleRoomVictory(room),
        onDefeat: _handleRoomDefeat,
      );
    } else {
      // Boss battle room
      gameScreen = SpeedBlitzGame(
        onVictory: () => _handleRoomVictory(room),
        onDefeat: _handleRoomDefeat,
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => gameScreen),
    );
  }

  void _handleRoomVictory(RoguelikeRoom room) {
    Navigator.of(context).pop(); // Exit game screen
    setState(() {
      _run.addScore(room.xpReward);
      if (_run.currentRoomIndex < _floor1Rooms.length - 1) {
        _run.currentRoomIndex++;
      } else {
        _run.advanceFloor();
      }
    });

    // Show Roguelike Boon / Relic Selection Modal
    _showRelicDraftModal();
  }

  void _handleRoomDefeat() {
    Navigator.of(context).pop();
    setState(() {
      _run.takeDamage();
    });

    if (_run.isDead) {
      _showGameOverModal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room Failed! 1 Heart lost. ${_run.lives} remaining.'),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showRelicDraftModal() {
    final draftOptions = RoguelikePerk.availablePerks.take(3).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ROGUELIKE BOON: CHOOSE A RELIC',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select an augmentation for the remainder of this run:',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 16),
              for (final perk in draftOptions) ...[
                BouncyTap(
                  onTap: () {
                    VocaHaptics.success();
                    Navigator.of(ctx).pop();
                    setState(() {
                      _run.activePerks.add(perk);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: perk.accentColor.withOpacity(0.5), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: perk.accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(perk.icon, color: perk.accentColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                perk.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                perk.description,
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showGameOverModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'EXPEDITION TERMINATED',
          style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your fluency run has ended. All progress in this expedition has been logged into your permanent mastery matrix.',
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text('Final Run Score: ${_run.score} PTS', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            Text('Floors Reached: Floor ${_run.currentFloor}', style: const TextStyle(color: Color(0xFF94A3B8))),
            Text('Relics Acquired: ${_run.activePerks.length}', style: const TextStyle(color: Color(0xFF94A3B8))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _run = RoguelikeRunState();
              });
            },
            child: const Text('NEW EXPEDITION', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Deep Roguelike Obsidian
      body: SafeArea(
        child: Column(
          children: [
            // Top HUD: Floor, Hearts, Relics, Difficulty Scalar
            _buildHud(),

            // Active Relics Strip
            if (_run.activePerks.isNotEmpty) _buildActiveRelicsStrip(),

            // Roguelike Map Dungeon View
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Current Floor Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF334155), width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FLOOR ${_run.currentFloor}: STREET CONVERSATION',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Difficulty Multiplier: ${_run.difficultyMultiplier.toStringAsFixed(2)}x',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_run.currentRoomIndex + 1} / ${_floor1Rooms.length}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Procedural Room Nodes
                  for (int i = 0; i < _floor1Rooms.length; i++) ...[
                    _buildRoomCard(room: _floor1Rooms[i], roomIndex: i),
                    if (i < _floor1Rooms.length - 1)
                      Center(
                        child: Container(
                          width: 2,
                          height: 22,
                          color: i < _run.currentRoomIndex
                              ? const Color(0xFF059669)
                              : const Color(0xFF334155),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHud() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          BouncyTap(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
            ),
          ),

          // Hearts
          Row(
            children: List.generate(_run.maxLives, (index) {
              final isAlive = index < _run.lives;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  isAlive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isAlive ? const Color(0xFFDC2626) : const Color(0xFF475569),
                  size: 20,
                ),
              );
            }),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_run.score} PTS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'COMBO ${_run.combo}x',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRelicsStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: const Color(0xFF111827),
      child: Row(
        children: [
          const Text(
            'ACTIVE RELICS:',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _run.activePerks.map((p) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: p.accentColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(p.icon, size: 12, color: p.accentColor),
                        const SizedBox(width: 4),
                        Text(
                          p.name,
                          style: TextStyle(color: p.accentColor, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard({required RoguelikeRoom room, required int roomIndex}) {
    final isCompleted = roomIndex < _run.currentRoomIndex;
    final isActive = roomIndex == _run.currentRoomIndex;
    final isLocked = roomIndex > _run.currentRoomIndex;

    Color borderColor;
    Color bgColor;
    if (isCompleted) {
      borderColor = const Color(0xFF059669);
      bgColor = const Color(0xFF064E3B).withOpacity(0.2);
    } else if (isActive) {
      borderColor = const Color(0xFF38BDF8);
      bgColor = const Color(0xFF1E293B);
    } else {
      borderColor = const Color(0xFF1E293B);
      bgColor = const Color(0xFF0F172A).withOpacity(0.6);
    }

    return BouncyTap(
      onTap: isActive ? () => _launchRoom(room) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isActive ? 2.0 : 1.0),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF059669)
                    : (isActive ? const Color(0xFF0284C7) : const Color(0xFF1E293B)),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_rounded
                    : (isActive ? Icons.play_arrow_rounded : Icons.lock_outline_rounded),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.title,
                        style: TextStyle(
                          color: isLocked ? const Color(0xFF64748B) : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${room.xpReward} XP',
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    room.description,
                    style: TextStyle(
                      color: isLocked ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
