import 'package:flutter/material.dart';
import '../../../core/curriculum/data/conversation_topics_catalog.dart';
import '../../../core/curriculum/services/curriculum_engine.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../lesson/screens/lesson_screen.dart';
import '../../roguelike/games/intonation_rider_game.dart';
import '../../roguelike/games/minimal_pair_game.dart';
import '../../roguelike/games/speed_blitz_game.dart';
import '../../roguelike/screens/expedition_map_screen.dart';
import '../../roguelike/screens/roguelike_run_screen.dart';

class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({super.key});

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen> {
  String _selectedCefr = 'ALL';
  String _searchQuery = '';

  final List<String> _cefrFilters = const ['ALL', 'A1', 'A2', 'B1', 'B2'];

  List<ConversationTopicMeta> get _filteredTopics {
    return ConversationTopicsCatalog.allTopics.where((t) {
      final matchesLevel =
          _selectedCefr == 'ALL' || t.cefrLevel.toUpperCase() == _selectedCefr;
      final matchesQuery = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.pedagogicalObjective.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.npcRole.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesLevel && matchesQuery;
    }).toList();
  }

  void _launchTopicUnit(ConversationTopicMeta topic) {
    VocaHaptics.medium();
    final unit = CurriculumEngine.generateUnitForTopic(topic.id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lessonTitle: '${unit.metadata.cefrLevel}: ${unit.metadata.title}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topics = _filteredTopics;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Obsidian Header
            _buildHeader(),

            const SizedBox(height: 20),

            // 2. Roguelike Run Hero Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildRoguelikeHeroCard(),
            ),

            const SizedBox(height: 28),

            // 3. Minigames Quick-Play Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'FLUENCY ARCADE MINIGAMES',
                style: VocaTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMinigameRow(
                    title: 'Acoustic Ear: Minimal Pair Duel',
                    subtitle: 'Train your brain to distinguish /θ/ vs /s/ and /iː/ vs /ɪ/ under noise.',
                    badge: 'EAR TRAINING',
                    accentColor: const Color(0xFF0284C7),
                    icon: Icons.graphic_eq_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MinimalPairDuelGame(
                            onVictory: () => Navigator.of(context).pop(),
                            onDefeat: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMinigameRow(
                    title: 'Intonation Wave Rider',
                    subtitle: 'Match native vocal pitch rise and fall contours with your voice live.',
                    badge: 'PITCH MATCH',
                    accentColor: const Color(0xFF4F46E5),
                    icon: Icons.waves_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => IntonationRiderGame(
                            onVictory: () => Navigator.of(context).pop(),
                            onDefeat: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMinigameRow(
                    title: 'Speed Blitz: 45s Survival',
                    subtitle: 'Rapid-fire conversational reflex game. Answer fast to build combos.',
                    badge: 'TIME ATTACK',
                    accentColor: const Color(0xFFE11D48),
                    icon: Icons.bolt_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SpeedBlitzGame(
                            onVictory: () => Navigator.of(context).pop(),
                            onDefeat: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 4. 100 Topics Registry (Search & Filter)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '100 CONVERSATION TOPICS',
                    style: VocaTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    '${topics.length} topics',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // CEFR Filter Chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _cefrFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _cefrFilters[index];
                  final isSelected = _selectedCefr == filter;
                  return BouncyTap(
                    onTap: () {
                      VocaHaptics.selection();
                      setState(() => _selectedCefr = filter);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    hintText: 'Search 100 topics, CEFR, or roles...',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Topics List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: topics.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final t = topics[index];
                final levelColor = t.cefrLevel == 'A1'
                    ? const Color(0xFF059669)
                    : (t.cefrLevel == 'A2'
                        ? const Color(0xFF0284C7)
                        : (t.cefrLevel == 'B1'
                            ? const Color(0xFFD97706)
                            : const Color(0xFFE11D48)));

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: levelColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t.cefrLevel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: levelColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${t.npcName} (${t.npcRole}) • ${t.category}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      BouncyTap(
                        onTap: () => _launchTopicUnit(t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 16,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARCADE & RUNS',
                  style: VocaTypography.caption.copyWith(
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Roguelike Fluency Gauntlet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.military_tech_rounded, size: 14, color: Color(0xFFFBBF24)),
                  SizedBox(width: 4),
                  Text(
                    'High: 2,450',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoguelikeHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withOpacity(0.15),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ROGUELIKE EXPEDITION',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.favorite_rounded, color: Color(0xFFDC2626), size: 16),
                  SizedBox(width: 4),
                  Text('5 Lives', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'The Spoken Gauntlet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Procedural branching map, authentic English card deck-building, tactical boss duels, and acoustic mini-puzzles.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: BouncyTap(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExpeditionMapScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'PROCEDURAL MAP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: BouncyTap(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RoguelikeRunScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'DRILLS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
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

  Widget _buildMinigameRow({
    required String title,
    required String subtitle,
    required String badge,
    required Color accentColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
