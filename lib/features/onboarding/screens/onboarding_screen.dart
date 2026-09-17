import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/adventure_cartoon_avatar.dart';
import '../../../core/widgets/bouncy_tap.dart';
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
  AdventureArchetype _selectedArchetype = AdventureArchetype.finn;
  int _selectedColor = 0xFF38BDF8;
  int _selectedGoal = 1; // 0: 10m, 1: 15m, 2: 25m

  final List<Map<String, dynamic>> _archetypes = [
    {
      'archetype': AdventureArchetype.finn,
      'name': 'Finn',
      'defaultColor': 0xFF38BDF8,
    },
    {
      'archetype': AdventureArchetype.jake,
      'name': 'Jake',
      'defaultColor': 0xFFFBBF24,
    },
    {
      'archetype': AdventureArchetype.bmo,
      'name': 'BMO',
      'defaultColor': 0xFF14B8A6,
    },
    {
      'archetype': AdventureArchetype.marceline,
      'name': 'Marceline',
      'defaultColor': 0xFFE2E8F0,
    },
    {
      'archetype': AdventureArchetype.princess,
      'name': 'Princesa',
      'defaultColor': 0xFFFBCFE8,
    },
  ];

  final List<int> _colors = [
    0xFF38BDF8,
    0xFFFBBF24,
    0xFF14B8A6,
    0xFFFB7185,
    0xFFA855F7,
    0xFF22C55E,
  ];

  final List<Map<String, String>> _goals = [
    {
      'time': '10 min',
      'title': 'Casual',
      'desc': '1 lección diaria para mantener la racha activa.',
    },
    {
      'time': '15 min',
      'title': 'Recomendado',
      'desc': 'Lecciones de gramática, fonética y práctica vocal.',
    },
    {
      'time': '25 min',
      'title': 'Aventurero Total',
      'desc': 'Inmersión rápida para hablar con soltura nativa.',
    },
  ];

  @override
  void initState() {
    super.initState();
    final storage = LocalStorageService();
    _nameController = TextEditingController(text: storage.getUserName());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleNext() {
    VocaHaptics.medium();
    if (_currentStep == 0) {
      final name = _nameController.text.trim().isEmpty ? 'Aventurero' : _nameController.text.trim();
      final storage = LocalStorageService();
      storage.setUserName(name);
      storage.setHeroArchetype(_selectedArchetype.name);
      storage.setHeroColor(_selectedColor);
      setState(() => _currentStep = 1);
    } else {
      final storage = LocalStorageService();
      storage.setUserGoal(_goals[_selectedGoal]['time']!);
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

              const SizedBox(height: 24),

              // Content based on step
              Expanded(
                child: _currentStep == 0 ? _buildStepHeroCreation() : _buildStepGoal(),
              ),

              // Bottom Primary Action
              VocaButton(
                text: _currentStep == 0 ? 'CONTINUAR' : '¡COMENZAR LA AVENTURA!',
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

  Widget _buildStepHeroCreation() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Live Animated Avatar Preview
          AdventureCartoonAvatar(
            archetype: _selectedArchetype,
            size: 104,
            customColor: Color(_selectedColor),
            expression: 'happy',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '¡CREA TU HÉROE!',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4F46E5),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '¿Cómo te llamas en esta aventura?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          // Name Input
          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Tu nombre o apodo...',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2.0),
              ),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 24),

          // Archetype Selector
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ELIGE TU PERSONAJE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF64748B),
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _archetypes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final arch = _archetypes[index]['archetype'] as AdventureArchetype;
                final name = _archetypes[index]['name'] as String;
                final isSelected = _selectedArchetype == arch;

                return BouncyTap(
                  onTap: () {
                    VocaHaptics.selection();
                    setState(() {
                      _selectedArchetype = arch;
                      _selectedColor = _archetypes[index]['defaultColor'] as int;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 78,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2.2 : 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AdventureCartoonAvatar(
                          archetype: arch,
                          size: 44,
                          isAnimated: false,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Color Palette
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'COLOR PRINCIPAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF64748B),
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _colors.map((c) {
              final isSelected = _selectedColor == c;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: BouncyTap(
                  onTap: () {
                    VocaHaptics.selection();
                    setState(() => _selectedColor = c);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
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
            'Aprende inglés de verdad por niveles secuenciales y sube de rango.',
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
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF4F46E5).withOpacity(0.08)
                  : Colors.black.withOpacity(0.02),
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
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
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
                color: Color(0xFF4F46E5),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
