import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../conversation/screens/conversation_screen.dart';
import '../../lesson/screens/lesson_screen.dart';
import '../models/level_node.dart';
import '../widgets/level_modal.dart';
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
  final List<LevelNodeModel> _nodes = const [
    LevelNodeModel(
      id: 'lvl_1',
      unitNumber: 1,
      levelNumber: 1,
      title: 'Level 1-1: Hello & Greetings',
      subtitle: 'Master basic everyday greetings and farewells',
      state: NodeState.completed,
      stars: 3,
      xpReward: 10,
      objectives: ['Say hello in 3 different contexts', 'Use proper polite responses', 'Shadow native speakers'],
      xOffset: 0.0,
    ),
    LevelNodeModel(
      id: 'lvl_2',
      unitNumber: 1,
      levelNumber: 2,
      title: 'Level 1-2: Numbers & Ordering',
      subtitle: 'Order coffee, snacks, and count items like a pro',
      state: NodeState.completed,
      stars: 3,
      xpReward: 10,
      objectives: ['Order 2 items at a counter', 'Understand prices and numbers', 'Practice clear vowels'],
      xOffset: -0.65,
    ),
    LevelNodeModel(
      id: 'lvl_3',
      unitNumber: 1,
      levelNumber: 3,
      title: 'Level 1-3: Food & Drinks',
      subtitle: 'Essential vocabulary for dining out and asking recommendations',
      state: NodeState.active,
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
      id: 'lvl_4',
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
      id: 'lvl_5',
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
      id: 'lvl_boss',
      unitNumber: 1,
      levelNumber: 6,
      title: 'Boss Fight: Airport Customs Officer',
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
  ];

  void _handleNodeTap(LevelNodeModel node) {
    if (node.state == NodeState.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete previous levels to unlock ${node.title}!'),
          backgroundColor: VocaColors.darkSlate,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (node.state == NodeState.boss) {
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
    return Scaffold(
      backgroundColor: VocaColors.backgroundNeutral,
      body: Column(
        children: [
          // Sticky Top Stats Bar
          const TopStickyBar(),

          // Scrollable Learning Path
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 90),
              children: [
                // Unit 1 Header Banner
                const UnitHeader(
                  unitNumber: 1,
                  title: 'Basic Survival & Daily Food',
                  description: 'Build core spoken fluency for everyday real-world interactions.',
                  progress: 0.50,
                ),

                const SizedBox(height: 10),

                // Winding Path Nodes
                for (int i = 0; i < _nodes.length; i++) ...[
                  PathNode(
                    node: _nodes[i],
                    onTap: () => _handleNodeTap(_nodes[i]),
                  ),
                  if (i == 1) ...[
                    // Minimalist Milestone Bonus Node
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: BouncyTap(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Milestone Bonus Claimed! +20 Gems earned.'),
                                backgroundColor: const Color(0xFF0F172A),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  offset: const Offset(0, 3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.card_giftcard_rounded, size: 16, color: Color(0xFFD97706)),
                                SizedBox(width: 8),
                                Text(
                                  'MILESTONE BONUS',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else if (i < _nodes.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Container(
                          width: 2,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _nodes[i].state == NodeState.completed
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
}

