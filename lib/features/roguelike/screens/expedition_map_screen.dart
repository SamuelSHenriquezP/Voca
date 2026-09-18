import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../cards/linguistic_card.dart';
import '../games/intonation_rider_game.dart';
import '../games/minimal_pair_game.dart';
import '../games/speed_blitz_game.dart';
import '../map/procedural_map_engine.dart';
import '../models/battle_state.dart';
import '../models/linguistic_relic.dart';
import '../story/chronicles_lore.dart';
import '../widgets/card_widget.dart';
import '../widgets/relic_draft_dialog.dart';
import 'card_battle_screen.dart';
import 'mystery_event_screen.dart';

class ExpeditionMapScreen extends StatefulWidget {
  final int initialFloor;

  const ExpeditionMapScreen({
    super.key,
    this.initialFloor = 1,
  });

  @override
  State<ExpeditionMapScreen> createState() => _ExpeditionMapScreenState();
}

class _ExpeditionMapScreenState extends State<ExpeditionMapScreen>
    with SingleTickerProviderStateMixin {
  late ProceduralMap _map;
  late List<LinguisticCard> _deck;
  late int _playerHp;
  int _playerMaxHp = 25;
  int _score = 0;
  final List<LinguisticRelic> _activeRelics = [];
  late AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();
    _playerHp = _playerMaxHp;
    _deck = List.from(DeckCatalog.starterDeck);
    _map = ProceduralMap.generateMap(floors: 8);
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnim.dispose();
    super.dispose();
  }

  BiomeStory get _currentBiome => BiomeStory.getForFloor(widget.initialFloor);

  void _onNodeTapped(MapNode node) async {
    if (!node.isAvailable || node.isCompleted) return;

    VocaHaptics.selection();

    switch (node.type) {
      case MapNodeType.battle:
      case MapNodeType.elite:
      case MapNodeType.boss:
        final monster = LinguisticMonster.createEncounter(
          isBoss: node.type == MapNodeType.boss,
          isElite: node.type == MapNodeType.elite,
          floor: node.floor,
        );

        final result = await Navigator.of(context).push<Map<String, dynamic>>(
          MaterialPageRoute(
            builder: (_) => CardBattleScreen(
              monster: monster,
              deck: _deck,
              playerHp: _playerHp,
              playerMaxHp: _playerMaxHp,
              floor: node.floor,
              relics: _activeRelics,
            ),
          ),
        );

        if (result != null && mounted) {
          setState(() {
            _playerHp = result['playerHp'] as int;
            _deck = List<LinguisticCard>.from(result['runDeck'] as List);
            _score += (result['xpEarned'] as int? ?? 100);

            if (_playerHp > 0) {
              _map.visitNode(node.id);
            }
          });

          // Relic draft for elite or boss victory
          if ((node.type == MapNodeType.elite || node.type == MapNodeType.boss) && _playerHp > 0) {
            final draftOptions = RelicCatalog.getRandomDraft(
              excludeIds: _activeRelics.map((r) => r.id).toList(),
            );
            if (draftOptions.isNotEmpty) {
              final newRelic = await RelicDraftDialog.show(context, options: draftOptions);
              if (newRelic != null && mounted) {
                setState(() {
                  _activeRelics.add(newRelic);
                  if (newRelic.id == 'vocal_cord_elixir') {
                    _playerMaxHp += 8;
                    _playerHp += 8;
                  }
                });
              }
            }
          }
        }
        break;

      case MapNodeType.intonationWave:
        final bool? won = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => IntonationRiderGame(
              onVictory: () => Navigator.of(context).pop(true),
              onDefeat: () => Navigator.of(context).pop(false),
            ),
          ),
        );
        if (won == true && mounted) {
          _handleMinigameVictory(node, xp: 140, isAcoustic: true);
        } else if (won == false && mounted) {
          _handleMinigameDefeat(damage: 6);
        }
        break;

      case MapNodeType.minimalPairDuel:
        final bool? won = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => MinimalPairDuelGame(
              onVictory: () => Navigator.of(context).pop(true),
              onDefeat: () => Navigator.of(context).pop(false),
            ),
          ),
        );
        if (won == true && mounted) {
          _handleMinigameVictory(node, xp: 150, isAcoustic: true);
        } else if (won == false && mounted) {
          _handleMinigameDefeat(damage: 8);
        }
        break;

      case MapNodeType.speedBlitz:
        final bool? won = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => SpeedBlitzGame(
              onVictory: () => Navigator.of(context).pop(true),
              onDefeat: () => Navigator.of(context).pop(false),
            ),
          ),
        );
        if (won == true && mounted) {
          _handleMinigameVictory(node, xp: 160, isAcoustic: false);
        } else if (won == false && mounted) {
          _handleMinigameDefeat(damage: 7);
        }
        break;

      case MapNodeType.mysteryEvent:
        final randomEvent = MysteryStoryEvent.allEvents[
            math.Random().nextInt(MysteryStoryEvent.allEvents.length)];
        final result = await Navigator.of(context).push<Map<String, dynamic>>(
          MaterialPageRoute(
            builder: (_) => MysteryEventScreen(
              event: randomEvent,
              playerHp: _playerHp,
              playerMaxHp: _playerMaxHp,
            ),
          ),
        );

        if (result != null && mounted) {
          setState(() {
            _playerHp = result['playerHp'] as int;
            _score += (result['scoreBonus'] as int? ?? 50);
            _map.visitNode(node.id);
          });
        }
        break;

      case MapNodeType.restShrine:
        _showRestShrineDialog(node);
        break;

      case MapNodeType.merchantShop:
        _showMerchantDialog(node);
        break;
    }
  }

  void _handleMinigameVictory(MapNode node, {required int xp, bool isAcoustic = false}) async {
    setState(() {
      _score += xp;
      if (isAcoustic && _activeRelics.any((r) => r.id == 'tuning_fork')) {
        _playerHp = (_playerHp + 12).clamp(0, _playerMaxHp);
      }
      _map.visitNode(node.id);
    });

    if (node.floor >= 3 && math.Random().nextDouble() < 0.35) {
      final draftOptions = RelicCatalog.getRandomDraft(
        excludeIds: _activeRelics.map((r) => r.id).toList(),
      );
      if (draftOptions.isNotEmpty) {
        final newRelic = await RelicDraftDialog.show(context, options: draftOptions);
        if (newRelic != null && mounted) {
          setState(() {
            _activeRelics.add(newRelic);
            if (newRelic.id == 'vocal_cord_elixir') {
              _playerMaxHp += 8;
              _playerHp += 8;
            }
          });
        }
      }
    }
  }

  void _handleMinigameDefeat({required int damage}) {
    setState(() {
      _playerHp = math.max(1, _playerHp - damage);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vocal setback: -$damage HP. Regroup and formulate your strategy!'),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }

  void _showRestShrineDialog(MapNode node) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.nightlight_round, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text('VOCAL OASIS', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Rest your vocal cords and formulate your thoughts. What will you do?',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _playerHp = (_playerHp + 8).clamp(0, _playerMaxHp);
                _map.visitNode(node.id);
              });
              VocaHaptics.success();
            },
            child: const Text('REST (+8 HP)',
                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _score += 150;
                _map.visitNode(node.id);
              });
              VocaHaptics.medium();
            },
            child: const Text('MEDITATE (+150 XP)',
                style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMerchantDialog(MapNode node) {
    final availableDraft = DeckCatalog.getRandomRewards(2);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.storefront_rounded, color: Color(0xFFFBBF24)),
                SizedBox(width: 8),
                Text(
                  "SCHOLAR'S BAZAAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Select a card to add freely to your expedition deck:',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: availableDraft.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final c = availableDraft[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _deck.add(c);
                        _map.visitNode(node.id);
                      });
                      VocaHaptics.success();
                    },
                    child: CardWidget(card: c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDeckViewer() {
    VocaHaptics.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF090D16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.style_rounded, color: Color(0xFF38BDF8), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'EXPEDITION DECK (${_deck.length} CARDS)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _deck.length,
                  itemBuilder: (context, index) {
                    return CardWidget(card: _deck[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final biome = _currentBiome;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top HUD Bar
            _buildTopHud(biome),

            // 2. Branching Node Map Canvas & Scroll View
            Expanded(
              child: SingleChildScrollView(
                reverse: true, // Start at floor 1 at the bottom, climb upwards!
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  children: List.generate(_map.totalFloors, (floorIndex) {
                    final floorNumber = floorIndex + 1;
                    final floorNodes = _map.getNodesForFloor(floorNumber);

                    return _buildFloorRow(floorNumber, floorNodes);
                  }),
                ),
              ),
            ),

            // 3. Bottom Run Controls Bar
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud(BiomeStory biome) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    biome.name.toUpperCase(),
                    style: TextStyle(
                      color: biome.secondaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    biome.cefrTier,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Player Health & Score
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
                    const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$_playerHp/$_playerMaxHp',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$_score XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      if (_activeRelics.isNotEmpty) ...[
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _activeRelics.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final relic = _activeRelics[index];
              return Tooltip(
                message: '${relic.name}\n${relic.description}',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: relic.color.withOpacity(0.5), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(relic.icon, size: 14, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        relic.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ],
  ),
);
}

  Widget _buildFloorRow(int floor, List<MapNode> nodes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Floor indicator divider
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFF1E293B), thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'FLOOR $floor',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFF1E293B), thickness: 1)),
            ],
          ),

          const SizedBox(height: 16),

          // Nodes Row (Lanes: 0, 1, 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: nodes.map((node) {
              return _buildNodeItem(node);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeItem(MapNode node) {
    final isAvailable = node.isAvailable && !node.isCompleted;
    final isCompleted = node.isCompleted;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final glowScale = isAvailable ? 1.0 + (_pulseAnim.value * 0.12) : 1.0;

        return Transform.scale(
          scale: glowScale,
          child: BouncyTap(
            onTap: isAvailable ? () => _onNodeTapped(node) : null,
            child: Column(
              children: [
                Container(
                  width: node.type == MapNodeType.boss ? 64 : 52,
                  height: node.type == MapNodeType.boss ? 64 : 52,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF1E293B)
                        : (isAvailable ? node.color : const Color(0xFF0F172A)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isAvailable
                          ? Colors.white
                          : (isCompleted ? const Color(0xFF334155) : node.color.withOpacity(0.3)),
                      width: isAvailable ? 2.5 : 1.5,
                    ),
                    boxShadow: isAvailable
                        ? [
                            BoxShadow(
                              color: node.color.withOpacity(0.6),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : node.icon,
                    color: isCompleted
                        ? const Color(0xFF64748B)
                        : (isAvailable ? Colors.white : node.color.withOpacity(0.5)),
                    size: node.type == MapNodeType.boss ? 30 : 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  node.type.name.toUpperCase(),
                  style: TextStyle(
                    color: isAvailable ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Deck Viewer Button
          BouncyTap(
            onTap: _openDeckViewer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.style_rounded, color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'VIEW DECK (${_deck.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Run Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'BRANCHING PROCEDURAL ASCENT',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
