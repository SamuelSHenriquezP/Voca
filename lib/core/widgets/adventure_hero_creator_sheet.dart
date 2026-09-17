import 'package:flutter/material.dart';
import '../storage/local_storage_service.dart';
import '../utils/haptic_feedback_utils.dart';
import '../utils/sound_effects.dart';
import 'adventure_cartoon_avatar.dart';
import 'bouncy_tap.dart';
import 'voca_button.dart';

class AdventureHeroCreatorSheet extends StatefulWidget {
  final VoidCallback? onSaved;

  const AdventureHeroCreatorSheet({super.key, this.onSaved});

  static Future<void> show(BuildContext context, {VoidCallback? onSaved}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdventureHeroCreatorSheet(onSaved: onSaved),
    );
  }

  @override
  State<AdventureHeroCreatorSheet> createState() => _AdventureHeroCreatorSheetState();
}

class _AdventureHeroCreatorSheetState extends State<AdventureHeroCreatorSheet> {
  late TextEditingController _nameController;
  late AdventureArchetype _selectedArchetype;
  late int _selectedColor;
  late String _selectedExpression;
  late String _selectedGoal;

  final List<Map<String, dynamic>> _archetypes = [
    {
      'archetype': AdventureArchetype.finn,
      'name': 'Finn',
      'desc': 'Aventurero intrépido con gorro de oso',
      'defaultColor': 0xFF38BDF8,
    },
    {
      'archetype': AdventureArchetype.jake,
      'name': 'Jake',
      'desc': 'Perro mágico y elástico de buen humor',
      'defaultColor': 0xFFFBBF24,
    },
    {
      'archetype': AdventureArchetype.bmo,
      'name': 'BMO',
      'desc': 'Robotito alegre de corazón gamer',
      'defaultColor': 0xFF14B8A6,
    },
    {
      'archetype': AdventureArchetype.marceline,
      'name': 'Marceline',
      'desc': 'Reina vampiro y rockera rebelde',
      'defaultColor': 0xFFE2E8F0,
    },
    {
      'archetype': AdventureArchetype.princess,
      'name': 'Princesa',
      'desc': 'Soberana y científica dulce',
      'defaultColor': 0xFFFBCFE8,
    },
  ];

  final List<int> _colors = [
    0xFF38BDF8, // Sky Blue
    0xFFFBBF24, // Golden Jake
    0xFF14B8A6, // Teal BMO
    0xFFFB7185, // Rose Pink
    0xFFA855F7, // Magic Purple
    0xFF22C55E, // Adventure Green
  ];

  final List<Map<String, String>> _expressions = [
    {'id': 'happy', 'label': 'Feliz'},
    {'id': 'wink', 'label': 'Guiño'},
    {'id': 'determined', 'label': 'Épico'},
    {'id': 'sweat', 'label': 'Sorprendido'},
  ];

  @override
  void initState() {
    super.initState();
    final storage = LocalStorageService();
    _nameController = TextEditingController(text: storage.getUserName());

    final archStr = storage.getHeroArchetype();
    _selectedArchetype = AdventureArchetype.values.firstWhere(
      (a) => a.name == archStr,
      orElse: () => AdventureArchetype.finn,
    );

    _selectedColor = storage.getHeroColor();
    _selectedExpression = storage.getHeroExpression();
    _selectedGoal = storage.getUserGoal();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveHero() {
    VocaHaptics.medium();
    SoundEffects.playSuccess();
    final name = _nameController.text.trim().isEmpty ? 'Aventurero' : _nameController.text.trim();
    final storage = LocalStorageService();
    storage.setUserName(name);
    storage.setHeroArchetype(_selectedArchetype.name);
    storage.setHeroColor(_selectedColor);
    storage.setHeroExpression(_selectedExpression);
    storage.setUserGoal(_selectedGoal);

    widget.onSaved?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tu Personaje y Sesión',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Big Animated Avatar Live Preview
                  Center(
                    child: Column(
                      children: [
                        AdventureCartoonAvatar(
                          archetype: _selectedArchetype,
                          size: 110,
                          customColor: Color(_selectedColor),
                          expression: _selectedExpression,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            'Estilo Hora de Aventura',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Hero Name Input
                  const Text(
                    'NOMBRE DEL HÉROE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Ingresa tu nombre...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2.0),
                      ),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),

                  const SizedBox(height: 22),

                  // Archetype Selector
                  const Text(
                    'ELIGE TU PERSONAJE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _archetypes.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
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
                              borderRadius: BorderRadius.circular(16),
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

                  const SizedBox(height: 22),

                  // Expression Selector
                  const Text(
                    'EXPRESIÓN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _expressions.map((e) {
                      final isSelected = _selectedExpression == e['id'];
                      return BouncyTap(
                        onTap: () {
                          VocaHaptics.selection();
                          setState(() => _selectedExpression = e['id']!);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            e['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  // Color Picker Chips
                  const Text(
                    'COLOR DE ESTILO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: _colors.map((c) {
                      final isSelected = _selectedColor == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: BouncyTap(
                          onTap: () {
                            VocaHaptics.selection();
                            setState(() => _selectedColor = c);
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Save Button
          SafeArea(
            top: false,
            child: VocaButton(
              text: '¡GUARDAR PERSONAJE!',
              variant: VocaButtonVariant.primary,
              width: double.infinity,
              onPressed: _saveHero,
            ),
          ),
        ],
      ),
    );
  }
}

