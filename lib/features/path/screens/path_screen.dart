import 'package:flutter/material.dart';
import '../../../core/curriculum/data/conversation_topics_catalog.dart';
import '../../../core/curriculum/services/adaptive_curriculum_engine.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../lesson/screens/lesson_screen.dart';
import '../models/level_node.dart';
import '../widgets/level_modal.dart';
import '../widgets/milestone_decorations.dart';
import '../widgets/path_node.dart';
import '../widgets/top_sticky_bar.dart';
import '../widgets/unit_header.dart';
import '../../../core/widgets/adventure_cartoon_avatar.dart';
import '../../../core/widgets/adventure_hero_creator_sheet.dart';

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

  int get _totalUnits => (ConversationTopicsCatalog.allTopics.length / 6).ceil();

  Map<String, dynamic> _getUnitData(int unitNumber) {
    final allTopics = ConversationTopicsCatalog.allTopics;
    final startIndex = (unitNumber - 1) * 6;
    final endIndex = (startIndex + 6 <= allTopics.length) ? startIndex + 6 : allTopics.length;
    final unitTopics = allTopics.sublist(startIndex, endIndex);

    final unlockedIds = LocalStorageService().getUnlockedTopicIds();
    final firstTopic = unitTopics.first;
    final xOffsets = [0.0, -0.65, 0.65, 0.0, -0.65, 0.0];

    int completedCount = 0;
    final List<LevelNodeModel> nodes = [];

    for (int i = 0; i < unitTopics.length; i++) {
      final topic = unitTopics[i];
      final isBoss = i == unitTopics.length - 1;
      final isUnlocked = unlockedIds.contains(topic.id);

      final nextTopicIndex = allTopics.indexWhere((t) => t.id == topic.id) + 1;
      final isNextUnlocked = nextTopicIndex < allTopics.length && unlockedIds.contains(allTopics[nextTopicIndex].id);

      NodeState state;
      if (isUnlocked) {
        if (isNextUnlocked) {
          state = NodeState.completed;
          completedCount++;
        } else {
          state = isBoss ? NodeState.boss : NodeState.active;
        }
      } else {
        state = NodeState.locked;
      }

      final focusTypes = [
        LevelFocusType.storyReading,   // Nivel 1: Historia Lore & Lectura
        LevelFocusType.syntaxBattle,   // Nivel 2: Batalla de Sintaxis
        LevelFocusType.listeningLab,   // Nivel 3: Laboratorio de Audio
        LevelFocusType.scienceExplore, // Nivel 4: Exploración Científica
        LevelFocusType.storyReading,   // Nivel 5: Crónica Avanzada de Lore
        LevelFocusType.dialogueBoss,   // Nivel 6: Jefe Conversacional
      ];
      final focusType = isBoss ? LevelFocusType.dialogueBoss : focusTypes[i % focusTypes.length];

      nodes.add(
        LevelNodeModel(
          id: topic.id,
          unitNumber: unitNumber,
          levelNumber: i + 1,
          title: isBoss
              ? 'Boss: ${topic.npcName} (${topic.npcRole})'
              : 'Level $unitNumber-${i + 1}: ${topic.title}',
          subtitle: topic.pedagogicalObjective,
          state: state,
          focusType: focusType,
          stars: state == NodeState.completed ? 3 : 0,
          xpReward: isBoss ? 50 : 15,
          objectives: [
            'Enfoque: ${focusType.name}',
            'Gramática: ${topic.targetGrammar}',
            'Fonética: ${topic.targetPhonemeFocus}',
            'Personaje: ${topic.npcName}',
          ],
          xOffset: xOffsets[i % xOffsets.length],
        ),
      );
    }

    final progress = nodes.isEmpty ? 0.0 : (completedCount / nodes.length).clamp(0.0, 1.0);

    return {
      'title': '${firstTopic.cefrLevel} • ${firstTopic.category}: ${firstTopic.title}',
      'description': firstTopic.pedagogicalObjective,
      'progress': progress,
      'nodes': nodes,
    };
  }

  void _handleNodeTap(LevelNodeModel node) {
    if (node.state == NodeState.locked) {
      VocaHaptics.light();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Completa los niveles anteriores para desbloquear "${node.title}"!'),
          backgroundColor: const Color(0xFF334155),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (node.state == NodeState.boss) {
      VocaHaptics.medium();
      LevelModal.show(context, node, () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LessonScreen(
              lessonTitle: 'Unidad ${node.unitNumber}: Desafío Final • ${node.title}',
              customExercises: AdaptiveCurriculumEngine.generateAdaptiveLessonForTopic(node.id),
              onCompleted: () {
                _onLevelCompleted(node.id);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      });
      return;
    }

    LevelModal.show(context, node, () {
      VocaHaptics.medium();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LessonScreen(
            lessonTitle: node.title,
            customExercises: AdaptiveCurriculumEngine.generateAdaptiveLessonForTopic(node.id),
            onCompleted: () {
              _onLevelCompleted(node.id);
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    });
  }

  void _onLevelCompleted(String completedTopicId) {
    LocalStorageService().unlockTopic(completedTopicId);
    final allTopics = ConversationTopicsCatalog.allTopics;
    final curIndex = allTopics.indexWhere((t) => t.id == completedTopicId);
    if (curIndex != -1 && curIndex < allTopics.length - 1) {
      LocalStorageService().unlockTopic(allTopics[curIndex + 1].id);
    }
    setState(() {});
  }

  LevelNodeModel? _findCurrentActiveNode(List<LevelNodeModel> nodes) {
    for (final node in nodes) {
      if (node.state == NodeState.active || node.state == NodeState.boss) {
        return node;
      }
    }
    for (final node in nodes) {
      if (node.state == NodeState.completed) {
        return node;
      }
    }
    return nodes.isNotEmpty ? nodes.first : null;
  }

  void _startDirectLesson(LevelNodeModel node) {
    VocaHaptics.medium();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lessonTitle: node.title,
          customExercises: AdaptiveCurriculumEngine.generateAdaptiveLessonForTopic(
            node.id,
            focusType: node.focusType,
          ),
          onCompleted: () {
            _onLevelCompleted(node.id);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _startUnitJumpExam(int unitNumber) {
    VocaHaptics.selection();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Examen de Salto de Unidad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Este examen pondrá a prueba tu dominio total de la Unidad $unitNumber.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• 8 ejercicios avanzados con límite estricto de vidas.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                  SizedBox(height: 4),
                  Text('• Incluye audios nativos reales y lecturas científicas.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                  SizedBox(height: 4),
                  Text('• Si lo superas, desbloquearás todos los niveles de la unidad + 100 XP.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF78350F))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              final examExercises = AdaptiveCurriculumEngine.generateJumpExamForUnit(unitNumber);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LessonScreen(
                    lessonTitle: '⚡ Examen de Salto: Unidad $unitNumber',
                    customExercises: examExercises,
                    onCompleted: () async {
                      final allTopics = ConversationTopicsCatalog.allTopics;
                      final startIndex = (unitNumber - 1) * 6;
                      final endIndex = (startIndex + 6 <= allTopics.length) ? startIndex + 6 : allTopics.length;
                      final unitTopicIds = allTopics.sublist(startIndex, endIndex).map((t) => t.id).toList();
                      final nextFirstId = endIndex < allTopics.length ? allTopics[endIndex].id : null;

                      final storage = LocalStorageService();
                      await storage.unlockUnitTopics(
                        unitTopicIds: unitTopicIds,
                        nextUnitFirstTopicId: nextFirstId,
                      );
                      await storage.addXp(100);
                      await storage.saveCollectedCard('card_jump_master');
                      storage.addDoubleXp(1);
                      storage.addShield(1);

                      if (mounted) {
                        setState(() {});
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('⚡ ¡Unidad $unitNumber superada por examen! +100 XP y niveles desbloqueados.'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
            child: const Text('Comenzar Examen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeUnit = _getUnitData(_selectedUnit);
    final List<LevelNodeModel> nodes = activeUnit['nodes'];
    final activeNode = _findCurrentActiveNode(nodes);
    final isBoss = activeNode?.state == NodeState.boss;
    final advanceLabel = activeNode != null
        ? (isBoss
            ? 'DESAFÍO FINAL • UNIDAD $_selectedUnit'
            : 'AVANZAR • NIVEL $_selectedUnit-${activeNode.levelNumber}')
        : 'AVANZAR';

    return Scaffold(
      backgroundColor: VocaColors.backgroundNeutral,
      body: Column(
        children: [
          // Sticky Top Stats Bar
          TopStickyBar(
            streakDays: LocalStorageService().getStreak(),
            gems: LocalStorageService().getXp() ~/ 10,
            hearts: LocalStorageService().getLives(),
            onProfileTap: () {
              VocaHaptics.selection();
              AdventureHeroCreatorSheet.show(
                context,
                onSaved: () => setState(() {}),
              );
            },
          ),

          // Unit Switcher Selector Strip
          _buildUnitSelector(),

          // Scrollable Learning Path
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Active Unit Header Banner
                UnitHeader(
                  unitNumber: _selectedUnit,
                  title: activeUnit['title'],
                  description: activeUnit['description'],
                  progress: activeUnit['progress'],
                  onJumpExamTap: () => _startUnitJumpExam(_selectedUnit),
                ),

                // Adventure Time Hero Session Banner
                Builder(
                  builder: (context) {
                    final storage = LocalStorageService();
                    final archStr = storage.getHeroArchetype();
                    final archetype = AdventureArchetype.values.firstWhere(
                      (a) => a.name == archStr,
                      orElse: () => AdventureArchetype.finn,
                    );
                    final heroColor = storage.getHeroColor();
                    final userName = storage.getUserName();

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              offset: const Offset(0, 3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AdventureCartoonAvatar(
                              archetype: archetype,
                              size: 52,
                              customColor: Color(heroColor),
                              expression: 'happy',
                              onTap: () {
                                AdventureHeroCreatorSheet.show(
                                  context,
                                  onSaved: () => setState(() {}),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'HÉROE',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF4F46E5),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Meta diaria: ${storage.getUserGoal()}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            BouncyTap(
                              onTap: () {
                                AdventureHeroCreatorSheet.show(
                                  context,
                                  onSaved: () => setState(() {}),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Personalizar',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 6),

                // Winding Path Nodes
                for (int i = 0; i < nodes.length; i++) ...[
                  PathNode(
                    node: nodes[i],
                    onTap: () => _handleNodeTap(nodes[i]),
                  ),

                  // Interspersed Milestone Decorations
                  if (i == 1) ...[
                    // Interactive Canvas Reward Chest
                    MilestoneRewardChest(
                      gemsReward: 25,
                      onClaimed: () {
                        LocalStorageService().addXp(25);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('¡Cofre desbloqueado! +25 XP ganados.'),
                            backgroundColor: const Color(0xFF0F172A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    ),
                  ] else if (i == 3) ...[
                    // Canvas Checkpoint Gate
                    MilestoneCheckpointGate(
                      title: 'Punto de Control Conversacional',
                      isPassed: nodes[i].state == NodeState.completed,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BouncyTap(
            onTap: () {
              if (activeNode != null) {
                _startDirectLesson(activeNode);
              }
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isBoss
                      ? const [Color(0xFFE11D48), Color(0xFFBE123C)]
                      : const [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isBoss ? const Color(0xFFE11D48) : const Color(0xFF4F46E5)).withOpacity(0.35),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    advanceLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
        itemCount: _totalUnits,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final unitNum = index + 1;
          final isSelected = _selectedUnit == unitNum;
          final sampleTopic = ConversationTopicsCatalog.allTopics[index * 6];

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
                  'UNIDAD $unitNum • ${sampleTopic.cefrLevel}',
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

