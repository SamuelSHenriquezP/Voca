import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/notion_avatar.dart';
import '../../../core/widgets/notion_avatar_creator_sheet.dart';
import '../../../core/widgets/voca_button.dart';
import '../../navigation/main_nav_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  late TextEditingController _nameController;

  int _head = 0;
  int _hair = 1;
  int _eyes = 0;
  int _mouth = 0;
  int _outfit = 0;
  int _backdrop = 0;

  int _selectedGoal = 1; // 0: 10m, 1: 15m, 2: 25m

  final List<String> _hairNames = [
    'Raya', 'Rulos', 'Moño', 'Bob', 'Flequillo', 'Gorro', 'Rapado', 'Coleta'
  ];

  final List<Color> _backdropColors = [
    const Color(0xFFF7F5F0), // Ivory
    const Color(0xFFEBF3EE), // Sage
    const Color(0xFFFDF0EA), // Terracotta
    const Color(0xFFEFF2F6), // Slate
    const Color(0xFFF4EFF8), // Lavender
  ];

  final List<Map<String, String>> _goals = [
    {
      'time': '10 min',
      'title': 'Consistencia Diaria',
      'desc': 'Práctica concisa para mantener el hábito y la retención léxica activa.',
    },
    {
      'time': '15 min',
      'title': 'Rigor Recomendado',
      'desc': 'Sintaxis profunda, fonética nativa y entrenamiento de escucha activa.',
    },
    {
      'time': '25 min',
      'title': 'Inmersión Intelectual',
      'desc': 'Lectura crítica, desafíos sintácticos y dominio fluido de nivel CEFR.',
    },
  ];

  @override
  void initState() {
    super.initState();
    final storage = LocalStorageService();
    _nameController = TextEditingController(text: storage.getUserName());
    _head = storage.getNotionHead();
    _hair = storage.getNotionHair();
    _eyes = storage.getNotionEyes();
    _mouth = storage.getNotionMouth();
    _outfit = storage.getNotionOutfit();
    _backdrop = storage.getNotionBackdrop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _randomizeAvatar() {
    final rand = Random();
    VocaHaptics.selection();
    setState(() {
      _head = rand.nextInt(4);
      _hair = rand.nextInt(8);
      _eyes = rand.nextInt(6);
      _mouth = rand.nextInt(5);
      _outfit = rand.nextInt(5);
      _backdrop = rand.nextInt(5);
    });
  }

  void _openFullCreator() {
    VocaHaptics.medium();
    NotionAvatarCreatorSheet.show(
      context,
      onSaved: () {
        final storage = LocalStorageService();
        setState(() {
          _head = storage.getNotionHead();
          _hair = storage.getNotionHair();
          _eyes = storage.getNotionEyes();
          _mouth = storage.getNotionMouth();
          _outfit = storage.getNotionOutfit();
          _backdrop = storage.getNotionBackdrop();
        });
      },
    );
  }

  void _handleNext() async {
    VocaHaptics.medium();
    final storage = LocalStorageService();
    if (_currentStep == 0) {
      final name = _nameController.text.trim().isEmpty ? 'Estudiante' : _nameController.text.trim();
      storage.setUserName(name);
      await storage.saveNotionAvatar(
        head: _head,
        hair: _hair,
        eyes: _eyes,
        mouth: _mouth,
        outfit: _outfit,
        backdrop: _backdrop,
      );
      setState(() => _currentStep = 1);
    } else {
      storage.setUserGoal(_goals[_selectedGoal]['time']!);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Progress Indicator
              Row(
                children: [
                  if (_currentStep > 0)
                    BouncyTap(
                      onTap: () {
                        VocaHaptics.light();
                        setState(() => _currentStep = 0);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF334155)),
                      ),
                    ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _currentStep == 0 ? 0.5 : 1.0,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
                        minHeight: 5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Content based on step
              Expanded(
                child: _currentStep == 0 ? _buildStepAvatarCreation() : _buildStepGoal(),
              ),

              // Bottom Primary Action
              VocaButton(
                text: _currentStep == 0 ? 'CONTINUAR' : 'COMENZAR APRENDIZAJE',
                variant: VocaButtonVariant.primary,
                width: double.infinity,
                onPressed: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepAvatarCreation() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Live Animated Notion Avatar Preview
          GestureDetector(
            onTap: _openFullCreator,
            child: NotionAvatar(
              head: _head,
              hair: _hair,
              eyes: _eyes,
              mouth: _mouth,
              outfit: _outfit,
              backdrop: _backdrop,
              size: 110,
            ),
          ),
          const SizedBox(height: 12),

          // Quick Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BouncyTap(
                onTap: _randomizeAvatar,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shuffle_rounded, size: 14, color: Color(0xFF0F172A)),
                      SizedBox(width: 6),
                      Text(
                        'Aleatorio',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              BouncyTap(
                onTap: _openFullCreator,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Diseñar Avatar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Name Input
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'TU NOMBRE O ALIAS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ej. Alex, Sofía, Elena...',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.8),
              ),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 20),

          // Quick Hair Selector
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ESTILO DE CABELLO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _hairNames.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _hair == index;
                return BouncyTap(
                  onTap: () {
                    VocaHaptics.selection();
                    setState(() => _hair = index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _hairNames[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // Quick Backdrop Selector
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'FONDO EDITORIAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_backdropColors.length, (index) {
              final isSelected = _backdrop == index;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: BouncyTap(
                  onTap: () {
                    VocaHaptics.selection();
                    setState(() => _backdrop = index);
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _backdropColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                        width: isSelected ? 2.5 : 1.2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, size: 18, color: Color(0xFF0F172A))
                        : null,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStepGoal() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'RITMO DE ESTUDIO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Elige tu compromiso diario',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aprende inglés riguroso a través de currículum CEFR adaptativo y lectura crítica.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          for (int i = 0; i < _goals.length; i++) ...[
            _buildGoalOption(
              index: i,
              time: _goals[i]['time']!,
              title: _goals[i]['title']!,
              desc: _goals[i]['desc']!,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalOption({
    required int index,
    required String time,
    required String title,
    required String desc,
  }) {
    final isSelected = _selectedGoal == index;

    return BouncyTap(
      onTap: () {
        VocaHaptics.selection();
        setState(() => _selectedGoal = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.black.withOpacity(0.04)
                  : Colors.black.withOpacity(0.01),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF0F172A),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
