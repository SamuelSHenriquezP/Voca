import 'package:flutter/material.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/mascot_avatar.dart';
import '../../../core/widgets/voca_button.dart';
import '../../navigation/main_nav_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  int _selectedLevel = 0; // 0: Principiante desde cero, 1: Intermedio
  int _selectedGoal = 1; // 0: 5m, 1: 15m, 2: 30m

  final List<Map<String, String>> _levels = [
    {
      'title': 'Comenzar desde cero',
      'subtitle': 'Aprende pronunciación básica, saludos y vocabulario inicial (A1-A2).',
      'tag': 'PRINCIPIANTE',
    },
    {
      'title': 'Ya tengo bases de inglés',
      'subtitle': 'Quiero destrabar mi habla con conversaciones de IA y fluidez (B1-B2).',
      'tag': 'INTERMEDIO',
    },
  ];

  final List<Map<String, String>> _goals = [
    {
      'time': '5 min',
      'title': 'Casual',
      'desc': '1 lección y 1 drill rápido al día.',
    },
    {
      'time': '15 min',
      'title': 'Recomendado',
      'desc': 'Drills diarios + conversación guiada por voz.',
    },
    {
      'time': '30 min',
      'title': 'Inmersión Total',
      'desc': 'Simulaciones completas y dominio de vocabulario.',
    },
  ];

  void _handleNext() {
    VocaHaptics.medium();
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
      );
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
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Content based on step
              Expanded(
                child: _currentStep == 0 ? _buildStepWelcome() : _buildStepGoal(),
              ),

              // Bottom Primary Action
              VocaButton(
                text: _currentStep == 0 ? 'CONTINUAR' : 'COMENZAR DESDE CERO',
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

  Widget _buildStepWelcome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Geometric Mascot Avatar
          const Center(
            child: MascotAvatar(size: 80),
          ),
          const SizedBox(height: 20),

          Center(
            child: Column(
              children: [
                Text(
                  'VOCA',
                  style: VocaTypography.heading1.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Don’t just tap English. Speak it.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            '¿Cuál es tu punto de partida?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Configuraremos tu ruta de aprendizaje personalizada desde cero.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Level Cards
          for (int i = 0; i < _levels.length; i++) ...[
            _buildLevelOption(
              index: i,
              title: _levels[i]['title']!,
              subtitle: _levels[i]['subtitle']!,
              tag: _levels[i]['tag']!,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildStepGoal() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'RITMO DIARIO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4F46E5),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Elige tu meta diaria de habla',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Construir un hábito diario constante es la clave para hablar con soltura.',
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

  Widget _buildLevelOption({
    required int index,
    required String title,
    required String subtitle,
    required String tag,
  }) {
    final isSelected = _selectedLevel == index;

    return BouncyTap(
      onTap: () {
        VocaHaptics.selection();
        setState(() => _selectedLevel = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(child: Icon(Icons.check, size: 12, color: Colors.white))
                  : null,
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
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.35,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
