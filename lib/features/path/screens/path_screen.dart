import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../conversation/screens/conversation_screen.dart';
import '../../lesson/screens/lesson_screen.dart';
import '../models/level_node.dart';
import '../widgets/level_modal.dart';
import '../widgets/milestone_decorations.dart';
import '../widgets/path_node.dart';
import '../widgets/top_sticky_bar.dart';
import '../widgets/unit_header.dart';

class PathScreen extends StatefulWidget {
  final VoidCallback? onOpenLesson;
  final VoidCallback? onOpenConversation;

  const PathScreen({
    super.key,
    this.onOpenLesson,
    this.onOpenConversation,
  });

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> {
  int _selectedUnit = 1;

  final Map<int, Map<String, dynamic>> _unitData = {
    1: {
      'title': 'Basic Survival & Daily Food',
      'description': 'Build core spoken fluency for everyday real-world interactions.',
      'progress': 0.0,
      'nodes': const [
        LevelNodeModel(
          id: 'u1_lvl_1',
          unitNumber: 1,
          levelNumber: 1,
          title: 'Level 1-1: Hello & Greetings',
          subtitle: 'Master basic everyday greetings and farewells',
          state: NodeState.active,
          stars: 0,
          xpReward: 10,
          objectives: ['Say hello in 3 different contexts', 'Use proper polite responses', 'Shadow native speakers'],
          xOffset: 0.0,
        ),
        LevelNodeModel(
          id: 'u1_lvl_2',
          unitNumber: 1,
          levelNumber: 2,
          title: 'Level 1-2: Numbers & Ordering',
          subtitle: 'Order coffee, snacks, and count items like a pro',
          state: NodeState.locked,
          stars: 0,
          xpReward: 10,
          objectives: ['Order 2 items at a counter', 'Understand prices and numbers', 'Practice clear vowels'],
          xOffset: -0.65,
        ),
        LevelNodeModel(
          id: 'u1_lvl_3',
          unitNumber: 1,
          levelNumber: 3,
          title: 'Level 1-3: Food & Drinks',
          subtitle: 'Essential vocabulary for dining out and asking recommendations',
          state: NodeState.locked,
          stars: 0,
          xpReward: 15,
          objectives: [
            'Ask "Could I get the check, please?"',
            'Recognize dietary terms (vegan, gluten)',
            'Score >80% on pronunciation shadowing'
          ],
          xOffset: 0.65,
        ),
        LevelNodeModel(
          id: 'u1_lvl_4',
          unitNumber: 1,
          levelNumber: 4,
          title: 'Level 1-4: Directions & Places',
          subtitle: 'Find your way around airports, stations, and streets',
          state: NodeState.locked,
          stars: 0,
          xpReward: 10,
          objectives: ['Ask for nearest subway station', 'Understand "turn left at the corner"'],
          xOffset: 0.0,
        ),
        LevelNodeModel(
          id: 'u1_lvl_5',
          unitNumber: 1,
          levelNumber: 5,
          title: 'Level 1-5: Daily Routine',
          subtitle: 'Describe your schedule and casual habits',
          state: NodeState.locked,
          stars: 0,
          xpReward: 10,
          objectives: ['Use simple present tense fluently', 'Connect sentences with "then" and "after"'],
          xOffset: -0.65,
        ),
        LevelNodeModel(
          id: 'u1_boss',
          unitNumber: 1,
          levelNumber: 6,
          title: 'Boss Battle: Airport Customs Officer',
          subtitle: 'Face a realistic AI voice conversation and pass inspection',
          state: NodeState.boss,
          stars: 0,
          xpReward: 50,
          objectives: [
            'Answer 4 continuous spoken questions',
            'State purpose of trip clearly',
            'Maintain fluent pacing under pressure'
          ],
          xOffset: 0.0,
        ),
      ],
    },
    2: {
      'title': 'Manhattan Cafe & Social Banter',
      'description': 'Natural small talk, ordering complex drinks, and casual idiom mastery.',
      'progress': 0.0,
      'nodes': const [
        LevelNodeModel(
          id: 'u2_lvl_1',
          unitNumber: 2,
          levelNumber: 1,
          title: 'Level 2-1: Espresso & Milk Craft',
          subtitle: 'Order bespoke coffee, oat milk, temperature, and syrups',
          state: NodeState.locked,
          stars: 0,
          xpReward: 15,
          objectives: ['Order flat white with oat milk', 'Ask for drink to go', 'Handle tip suggestions'],
          xOffset: 0.0,
        ),
        LevelNodeModel(
          id: 'u2_lvl_2',
          unitNumber: 2,
          levelNumber: 2,
          title: 'Level 2-2: Table for Two',
          subtitle: 'Host seating, waiting lists, and reservation inquiries',
          state: NodeState.locked,
          stars: 0,
          xpReward: 15,
          objectives: ['Ask for an outdoor patio table', 'Inquire about wait time'],
          xOffset: -0.65,
        ),
        LevelNodeModel(
          id: 'u2_lvl_3',
          unitNumber: 2,
          levelNumber: 3,
          title: 'Level 2-3: Dietary Restrictions',
          subtitle: 'Communicate allergies and special preparation requests',
          state: NodeState.locked,
          stars: 0,
          xpReward: 15,
          objectives: ['Explain peanut allergy clearly', 'Confirm dairy-free substitutes'],
          xOffset: 0.65,
        ),
        LevelNodeModel(
          id: 'u2_boss',
          unitNumber: 2,
          levelNumber: 4,
          title: 'Boss Battle: Barista Mateo Rush Hour',
          subtitle: 'Rapid spoken dialogue during morning NYC coffee rush',
          state: NodeState.boss,
          stars: 0,
          xpReward: 50,
          objectives: ['Order 2 custom drinks quickly', 'Pay with contactless Apple Pay', 'Engage in light weather banter'],
          xOffset: 0.0,
        ),
      ],
    },
    3: {
      'title': 'Global Travel & Navigation',
      'description': 'Flight connections, baggage claims, taxis, and underground transit.',
      'progress': 0.0,
      'nodes': const [
        LevelNodeModel(
          id: 'u3_lvl_1',
          unitNumber: 3,
          levelNumber: 1,
          title: 'Level 3-1: Terminal Transit',
          subtitle: 'Navigating gate changes and boarding passes',
          state: NodeState.locked,
          stars: 0,
          xpReward: 15,
          objectives: ['Understand gate change announcements', 'Ask for terminal shuttle'],
          xOffset: 0.0,
        ),
        LevelNodeModel(
          id: 'u3_boss',
          unitNumber: 3,
          levelNumber: 2,
          title: 'Boss Battle: Hotel Concierge Desk',
          subtitle: 'Request late check-out and restaurant recommendations',
          state: NodeState.boss,
          stars: 0,
          xpReward: 50,
          objectives: ['Negotiate 1:00 PM late check-out', 'Ask for hidden local bistro recommendation'],
          xOffset: 0.0,
        ),
      ],
    },
    4: {
      'title': 'High-Stakes Career & Meetings',
      'description': 'Presenting project milestones, negotiating terms, and technical interviews.',
      'progress': 0.0,
      'nodes': const [
        LevelNodeModel(
          id: 'u4_lvl_1',
          unitNumber: 4,
          levelNumber: 1,
          title: 'Level 4-1: Executive Introductions',
          subtitle: 'Pitching your professional background and core competencies',
          state: NodeState.locked,
          stars: 0,
          xpReward: 20,
          objectives: ['Deliver 60-second elevator pitch', 'Articulate architectural trade-offs'],
          xOffset: 0.0,
        ),
        LevelNodeModel(
          id: 'u4_boss',
          unitNumber: 4,
          levelNumber: 2,
          title: 'Boss Battle: VP of Product Interview',
          subtitle: 'High-intensity behavioral & leadership spoken interview',
          state: NodeState.boss,
          stars: 0,
          xpReward: 100,
          objectives: ['Answer behavioral STAR question', 'Defend technical decision under critique'],
          xOffset: 0.0,
        ),
      ],
    },
  };

  void _handleNodeTap(LevelNodeModel node) {
    if (node.state == NodeState.locked) {
      VocaHaptics.light();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete previous levels to unlock ${node.title}!'),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (node.state == NodeState.boss) {
      VocaHaptics.medium();
      if (widget.onOpenConversation != null) {
        widget.onOpenConversation!();
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ConversationScreen(),
          ),
        );
      }
      return;
    }

    LevelModal.show(context, node, () {
      if (widget.onOpenLesson != null) {
        widget.onOpenLesson!();
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LessonScreen(lessonTitle: node.title),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeUnit = _unitData[_selectedUnit]!;
    final List<LevelNodeModel> nodes = activeUnit['nodes'];

    return Scaffold(
      backgroundColor: VocaColors.backgroundNeutral,
      body: Column(
        children: [
          // Sticky Top Stats Bar
          const TopStickyBar(),

          // Unit Switcher Selector Strip
          _buildUnitSelector(),

          // Scrollable Learning Path
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 90),
              children: [
                // Active Unit Header Banner
                UnitHeader(
                  unitNumber: _selectedUnit,
                  title: activeUnit['title'],
                  description: activeUnit['description'],
                  progress: activeUnit['progress'],
                ),

                const SizedBox(height: 10),

                // Winding Path Nodes
                for (int i = 0; i < nodes.length; i++) ...[
                  PathNode(
                    node: nodes[i],
                    onTap: () => _handleNodeTap(nodes[i]),
                  ),

                  // Interspersed Milestone Decorations
                  if (i == 1 && _selectedUnit == 1) ...[
                    // Interactive Canvas Reward Chest
                    MilestoneRewardChest(
                      gemsReward: 25,
                      onClaimed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Bonus Chest Claimed! +25 Gems earned.'),
                            backgroundColor: const Color(0xFF0F172A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    ),
                  ] else if (i == 3 && _selectedUnit == 1) ...[
                    // Canvas Checkpoint Gate
                    const MilestoneCheckpointGate(
                      title: 'Intermediate Conversational Barrier',
                      isPassed: false,
                    ),
                  ] else if (i < nodes.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Container(
                          width: 2,
                          height: 24,
                          decoration: BoxDecoration(
                            color: nodes[i].state == NodeState.completed
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Container(
      height: 46,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final unitNum = index + 1;
          final isSelected = _selectedUnit == unitNum;

          return BouncyTap(
            onTap: () {
              VocaHaptics.selection();
              setState(() => _selectedUnit = unitNum);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'UNIT $unitNum',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

