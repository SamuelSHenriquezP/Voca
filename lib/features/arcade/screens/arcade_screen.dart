import 'package:flutter/material.dart';
import '../../../core/curriculum/data/conversation_topics_catalog.dart';
import '../../../core/curriculum/services/adaptive_curriculum_engine.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/voca_avatar.dart';
import '../../../core/widgets/voca_button.dart';
import '../../lesson/models/exercise.dart';
import '../../lesson/screens/lesson_screen.dart';

class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({super.key});

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen> {
  String _selectedCefr = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _cefrFilters = const ['ALL', 'A1', 'A2', 'B1', 'B2', 'C1'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ConversationTopicMeta> get _filteredTopics {
    return ConversationTopicsCatalog.allTopics.where((t) {
      final matchesLevel =
          _selectedCefr == 'ALL' || t.cefrLevel.toUpperCase() == _selectedCefr;
      final matchesQuery = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.pedagogicalObjective.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.targetGrammar.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.npcName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesLevel && matchesQuery;
    }).toList();
  }

  void _launchTopicLesson(ConversationTopicMeta topic) {
    VocaHaptics.medium();
    final exercises = AdaptiveCurriculumEngine.generateAdaptiveLessonForTopic(topic.id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lessonTitle: '${topic.cefrLevel}: ${topic.title}',
          customExercises: exercises,
          onCompleted: () {
            LocalStorageService().unlockTopic(topic.id);
            setState(() {});
          },
        ),
      ),
    );
  }

  void _launchQuickSkillDrill(DrillType type, String title) {
    VocaHaptics.medium();
    final topics = ConversationTopicsCatalog.allTopics;
    final List<ExerciseModel> drills = [];

    for (int i = 0; i < 4; i++) {
      final topic = topics[i % topics.length];
      final lesson = AdaptiveCurriculumEngine.generateAdaptiveLessonForTopic(topic.id);
      final matching = lesson.firstWhere(
        (e) => e.type == type,
        orElse: () => lesson.first,
      );
      drills.add(matching);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lessonTitle: 'Práctica Rápida: $title',
          customExercises: drills,
          onCompleted: () {
            LocalStorageService().addXp(20);
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topics = _filteredTopics;
    final unlockedCount = LocalStorageService().getUnlockedTopicIds().length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // 1. Clean Top Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TEMAS Y NIVELES',
                              style: VocaTypography.caption.copyWith(
                                color: VocaColors.primaryPurple,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Catálogo de Aprendizaje',
                              style: VocaTypography.heading1.copyWith(
                                fontSize: 24,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFC7D2FE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 16, color: VocaColors.primaryPurple),
                              const SizedBox(width: 6),
                              Text(
                                '$unlockedCount/300 Desbloqueados',
                                style: VocaTypography.caption.copyWith(
                                  color: VocaColors.primaryPurple,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '300 temas con ejercicios estructurados de gramática, sintaxis y pronunciación directa.',
                      style: VocaTypography.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Focused Quick Skill Drills
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ENTRENAMIENTO FOCALIZADO',
                      style: VocaTypography.caption.copyWith(
                        letterSpacing: 1.1,
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSkillCard(
                            icon: Icons.format_list_numbered_rounded,
                            title: 'Sintaxis',
                            subtitle: 'Ordenar frases',
                            color: const Color(0xFF4F46E5),
                            onTap: () => _launchQuickSkillDrill(
                              DrillType.sentenceScramble,
                              'Sintaxis y Orden de Palabras',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSkillCard(
                            icon: Icons.edit_note_rounded,
                            title: 'Completar',
                            subtitle: 'Preposiciones',
                            color: const Color(0xFF059669),
                            onTap: () => _launchQuickSkillDrill(
                              DrillType.clozeFill,
                              'Completar Espacios y Colocaciones',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSkillCard(
                            icon: Icons.graphic_eq_rounded,
                            title: 'Acento Silábico',
                            subtitle: 'Ritmo y cadencia',
                            color: const Color(0xFFD97706),
                            onTap: () => _launchQuickSkillDrill(
                              DrillType.syllableStress,
                              'Acento Silábico y Ritmo',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSkillCard(
                            icon: Icons.record_voice_over_rounded,
                            title: 'Shadowing',
                            subtitle: 'Pronunciación',
                            color: const Color(0xFFE11D48),
                            onTap: () => _launchQuickSkillDrill(
                              DrillType.shadowing,
                              'Shadowing y Fluidez Oral',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 3. Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Buscar tema o gramática (ej: Present Perfect, Coffee, Airport)...',
                    hintStyle: VocaTypography.bodySmall,
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: VocaColors.primaryPurple, width: 2),
                    ),
                  ),
                ),
              ),
            ),

            // 4. CEFR Level Filter Pills
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _cefrFilters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _cefrFilters[index];
                    final isSelected = _selectedCefr == filter;

                    return BouncyTap(
                      onTap: () => setState(() => _selectedCefr = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? VocaColors.primaryPurple : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? VocaColors.primaryPurple : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: VocaColors.primaryPurple.withOpacity(0.25),
                                    offset: const Offset(0, 3),
                                    blurRadius: 6,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            filter == 'ALL' ? 'Todos los Niveles' : 'Nivel $filter',
                            style: VocaTypography.caption.copyWith(
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 5. Results Counter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${topics.length} TEMAS ENCONTRADOS',
                      style: VocaTypography.caption.copyWith(
                        letterSpacing: 1.1,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Toca para practicar',
                      style: VocaTypography.caption.copyWith(color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ),

            // 6. Topic Cards List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final topic = topics[index];
                    final isUnlocked = LocalStorageService().getUnlockedTopicIds().contains(topic.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isUnlocked ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar
                                  VocaAvatar.fromId(
                                    topic.npcName,
                                    size: 46,
                                    isAnimated: false,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getLevelColor(topic.cefrLevel).withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                topic.cefrLevel,
                                                style: VocaTypography.caption.copyWith(
                                                  color: _getLevelColor(topic.cefrLevel),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              topic.category.toUpperCase(),
                                              style: VocaTypography.caption.copyWith(
                                                color: const Color(0xFF94A3B8),
                                                fontSize: 10,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          topic.title,
                                          style: VocaTypography.heading3.copyWith(
                                            fontSize: 16,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                topic.pedagogicalObjective,
                                style: VocaTypography.bodySmall.copyWith(
                                  color: const Color(0xFF475569),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Grammar & Phonetics badges
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.menu_book_rounded, size: 12, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Text(
                                          topic.targetGrammar,
                                          style: VocaTypography.caption.copyWith(
                                            color: const Color(0xFF334155),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.record_voice_over_rounded, size: 12, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Text(
                                          topic.targetPhonemeFocus,
                                          style: VocaTypography.caption.copyWith(
                                            color: const Color(0xFF334155),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Direct action button
                              VocaButton(
                                text: 'INICIAR NIVEL (+15 XP)',
                                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                                variant: isUnlocked ? VocaButtonVariant.primary : VocaButtonVariant.neutral,
                                isFullWidth: true,
                                height: 44,
                                onPressed: () => _launchTopicLesson(topic),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: topics.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: VocaTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: VocaTypography.caption.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return const Color(0xFF059669);
      case 'A2':
        return const Color(0xFF0284C7);
      case 'B1':
        return const Color(0xFF4F46E5);
      case 'B2':
        return const Color(0xFFD97706);
      case 'C1':
        return const Color(0xFFE11D48);
      default:
        return const Color(0xFF64748B);
    }
  }
}
