import 'package:flutter/material.dart';
import '../../../core/curriculum/data/conversation_topics_catalog.dart';
import '../../../core/curriculum/services/adaptive_curriculum_engine.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/notion_avatar_creator_sheet.dart';
import '../../lesson/screens/lesson_screen.dart';
import '../models/level_node.dart';
import '../widgets/level_modal.dart';
import '../widgets/syllabus_module_card.dart';
import '../widgets/top_sticky_bar.dart';
import '../widgets/unit_header.dart';

/// Minimalist, structured curriculum syllabus screen for VOCA.
/// Replaces the winding snake Duolingo path with an editorial, academic syllabus roadmap.
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

    final storage = LocalStorageService();
    final unlockedIds = storage.getUnlockedTopicIds();
    final firstTopic = unitTopics.first;

    int completedCount = 0;
    final List<LevelNodeModel> nodes = [];

    for (int i = 0; i < unitTopics.length; i++) {
      final topic = unitTopics[i];
      final isBoss = i == unitTopics.length - 1;
      final isUnlocked = unlockedIds.contains(topic.id);
      final isCompleted = storage.isTopicCompleted(topic.id);

      final nextTopicIndex = allTopics.indexWhere((t) => t.id == topic.id) + 1;
      final isNextUnlocked = nextTopicIndex < allTopics.length && unlockedIds.contains(allTopics[nextTopicIndex].id);

      NodeState state;
      if (isCompleted || isNextUnlocked) {
        state = NodeState.completed;
        completedCount++;
      } else if (isUnlocked) {
        state = isBoss ? NodeState.boss : NodeState.active;
      } else {
        state = NodeState.locked;
      }

      final focusTypes = [
        LevelFocusType.storyReading,   // Módulo 1: Lectura Crítica & Vocabulario
        LevelFocusType.syntaxBattle,   // Módulo 2: Precisión Sintáctica
        LevelFocusType.listeningLab,   // Módulo 3: Comprensión Auditiva Nativa
        LevelFocusType.scienceExplore, // Módulo 4: Exploración Científica & Contexto
        LevelFocusType.storyReading,   // Módulo 5: Análisis de Textos Complejos
        LevelFocusType.dialogueBoss,   // Módulo 6: Evaluación Final de Dominio
      ];
      final focusType = isBoss ? LevelFocusType.dialogueBoss : focusTypes[i % focusTypes.length];

      nodes.add(
        LevelNodeModel(
          id: topic.id,
          unitNumber: unitNumber,
          levelNumber: i + 1,
          title: isBoss
              ? 'Evaluación de Dominio: ${topic.npcName}'
              : topic.title,
          subtitle: topic.pedagogicalObjective,
          state: state,
          focusType: focusType,
          stars: state == NodeState.completed ? 3 : 0,
          xpReward: isBoss ? 50 : 15,
          objectives: [
            'Enfoque: ${focusType.name}',
            'Gramática: ${topic.targetGrammar}',
            'Fonética: ${topic.targetPhonemeFocus}',
            'Interlocutor: ${topic.npcName} (${topic.npcRole})',
          ],
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
          content: Text('Completa los módulos anteriores para desbloquear "${node.title}".'),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              lessonTitle: 'Unidad ${node.unitNumber}: Evaluación Final • ${node.title}',
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
    });
  }

  void _onLevelCompleted(String completedTopicId) async {
    final storage = LocalStorageService();
    await storage.markTopicCompleted(completedTopicId);
    await storage.unlockTopic(completedTopicId);
    final allTopics = ConversationTopicsCatalog.allTopics;
    final curIndex = allTopics.indexWhere((t) => t.id == completedTopicId);
    if (curIndex != -1 && curIndex < allTopics.length - 1) {
      await storage.unlockTopic(allTopics[curIndex + 1].id);
    }
    if (mounted) {
      setState(() {});
    }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: Color(0xFF0F172A), size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Examen de Suficiencia',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta evaluación certificará tu dominio de la Unidad $unitNumber para avanzar de inmediato.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• 8 ejercicios avanzados con límite estricto de vidas.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  SizedBox(height: 4),
                  Text('• Incluye fonética nativa, sintaxis y lectura crítica.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  SizedBox(height: 4),
                  Text('• Otorga acreditación de unidad completa + 100 XP.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
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
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              final examExercises = AdaptiveCurriculumEngine.generateJumpExamForUnit(unitNumber);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LessonScreen(
                    lessonTitle: '⚡ Examen de Suficiencia: Unidad $unitNumber',
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
                            content: Text('Unidad $unitNumber acreditada con éxito (+100 XP).'),
                            backgroundColor: const Color(0xFF0F172A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
            child: const Text('Comenzar Examen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
            ? 'EVALUACIÓN FINAL • UNIDAD $_selectedUnit'
            : 'CONTINUAR • MÓDULO $_selectedUnit.${activeNode.levelNumber}')
        : 'CONTINUAR';

    return Scaffold(
      backgroundColor: VocaColors.backgroundNeutral,
      body: Column(
        children: [
          // Ultra-minimalist Top Sticky Bar
          TopStickyBar(
            streakDays: LocalStorageService().getStreak(),
            gems: LocalStorageService().getXp() ~/ 10,
            hearts: LocalStorageService().getLives(),
            onProfileTap: () {
              VocaHaptics.selection();
              NotionAvatarCreatorSheet.show(
                context,
                onSaved: () => setState(() {}),
              );
            },
          ),

          // Unit Switcher Selector Strip
          _buildUnitSelector(),

          // Scrollable Structured Syllabus Roadmap
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Active Unit Header Briefing
                UnitHeader(
                  unitNumber: _selectedUnit,
                  title: activeUnit['title'],
                  description: activeUnit['description'],
                  progress: activeUnit['progress'],
                  onJumpExamTap: () => _startUnitJumpExam(_selectedUnit),
                ),

                // Active Lesson Quick Launcher Card
                if (activeNode != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                    child: BouncyTap(
                      onTap: () => _startDirectLesson(activeNode),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    advanceLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activeNode.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'INICIAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 4),

                // Vertical Syllabus Modules Roadmap
                for (int i = 0; i < nodes.length; i++) ...[
                  SyllabusModuleCard(
                    node: nodes[i],
                    onTap: () => _handleNodeTap(nodes[i]),
                  ),

                  // Minimalist Vertical Hairline Connector
                  if (i < nodes.length - 1)
                    Center(
                      child: Container(
                        width: 1.5,
                        height: 12,
                        color: nodes[i].state == NodeState.completed
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Container(
      height: 44,
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
        separatorBuilder: (_, _) => const SizedBox(width: 8),
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
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
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
                    letterSpacing: 0.5,
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
