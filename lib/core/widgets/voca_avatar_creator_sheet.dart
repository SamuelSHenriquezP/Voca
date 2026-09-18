import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../storage/local_storage_service.dart';
import '../utils/haptic_feedback_utils.dart';
import '../utils/sound_effects.dart';
import 'bouncy_tap.dart';
import 'voca_avatar.dart';
import 'voca_button.dart';

class VocaAvatarCreatorSheet extends StatefulWidget {
  final VoidCallback? onSaved;

  const VocaAvatarCreatorSheet({super.key, this.onSaved});

  static Future<void> show(BuildContext context, {VoidCallback? onSaved}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VocaAvatarCreatorSheet(onSaved: onSaved),
    );
  }

  @override
  State<VocaAvatarCreatorSheet> createState() => _VocaAvatarCreatorSheetState();
}

class _VocaAvatarCreatorSheetState extends State<VocaAvatarCreatorSheet> {
  late TextEditingController _nameController;
  late int _head;
  late int _hair;
  late int _eyes;
  late int _mouth;
  late int _outfit;
  late int _backdrop;
  late String _goal;

  int _currentSection = 0;
  final List<String> _sections = [
    'Cabello',
    'Mirada / Gafas',
    'Rostro / Barba',
    'Ropa',
    'Cara',
    'Fondo',
  ];

  final List<String> _hairNames = [
    'Raya al lado',
    'Rizos messy',
    'Moño alto',
    'Bob chic',
    'Flequillo',
    'Gorro Beanie',
    'Rapado clean',
    'Coleta',
    'Ondulado medio',
    'Dreadlocks / Trenzas',
    'Tupé Pompadour',
    'Afro esponjoso',
    'Gorra delantera',
    'Gorra hacia atrás',
    'Melena lisa suelta',
    'Calvo pulido',
  ];

  final List<String> _eyesNames = [
    'Gafas Redondas',
    'Ojos Atentos',
    'Gafas Cuadradas',
    'Guiño',
    'Sonrisa amable',
    'Gafas de sol',
    'Monóculo retro',
    'Gafas Cat-eye',
    'Mirada curiosa',
    'Gafas hexagonales',
    'Ojos zen relajados',
    'Gafas de lectura',
  ];

  final List<String> _mouthNames = [
    'Sonrisa sutil',
    'Sonrisa abierta',
    'Concentrado',
    'Bigote Clásico',
    'Barba recortada',
    'Pipa intelectual',
    'Sonrisa pícara',
    'Barba hipster',
    'Perilla Van Dyke',
    'Sonrisa con hoyuelos',
  ];

  final List<String> _outfitNames = [
    'Cuello cisne',
    'Sudadera',
    'Camisa cuello',
    'Camiseta',
    'Bufanda',
    'Blazer & Corbata',
    'Chaqueta Denim',
    'Cuello Polo',
    'Cazadora Bomber',
    'Camisa hawaiana',
  ];

  final List<String> _headNames = [
    'Oval clásico',
    'Mandíbula angular',
    'Redonda',
    'Alargada',
    'Corazón / Fina',
    'Diamante',
  ];

  final List<Map<String, dynamic>> _backdropOptions = const [
    {'name': 'Marfil crema', 'color': Color(0xFFFAF9F6)},
    {'name': 'Salvia suave', 'color': Color(0xFFF0FDF4)},
    {'name': 'Lavanda', 'color': Color(0xFFF5F3FF)},
    {'name': 'Melocotón', 'color': Color(0xFFFFF7ED)},
    {'name': 'Carbón', 'color': Color(0xFF18181B)},
    {'name': 'Azul Nórdico', 'color': Color(0xFFF0F9FF)},
    {'name': 'Menta Fresca', 'color': Color(0xFFF0FDFA)},
    {'name': 'Rosa Palo', 'color': Color(0xFFFFF1F2)},
    {'name': 'Ámbar Cálido', 'color': Color(0xFFFFFBEB)},
    {'name': 'Pizarra Obsidiana', 'color': Color(0xFF0F172A)},
  ];

  final List<String> _goals = ['10 min', '15 min', '25 min', '40 min'];

  @override
  void initState() {
    super.initState();
    final storage = LocalStorageService();
    _nameController = TextEditingController(text: storage.getUserName());
    _head = storage.getVocaHead();
    _hair = storage.getVocaHair();
    _eyes = storage.getVocaEyes();
    _mouth = storage.getVocaMouth();
    _outfit = storage.getVocaOutfit();
    _backdrop = storage.getVocaBackdrop();
    _goal = storage.getUserGoal();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _randomize() {
    VocaHaptics.selection();
    final rand = math.Random();
    setState(() {
      _head = rand.nextInt(_headNames.length);
      _hair = rand.nextInt(_hairNames.length);
      _eyes = rand.nextInt(_eyesNames.length);
      _mouth = rand.nextInt(_mouthNames.length);
      _outfit = rand.nextInt(_outfitNames.length);
      _backdrop = rand.nextInt(_backdropOptions.length);
    });
  }

  void _save() async {
    VocaHaptics.medium();
    SoundEffects.playSuccess();
    final name = _nameController.text.trim().isEmpty ? 'Alex' : _nameController.text.trim();
    final storage = LocalStorageService();
    storage.setUserName(name);
    storage.setUserGoal(_goal);
    await storage.saveVocaAvatar(
      head: _head,
      hair: _hair,
      eyes: _eyes,
      mouth: _mouth,
      outfit: _outfit,
      backdrop: _backdrop,
    );
    widget.onSaved?.call();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFFAF9F6), // Warm paper
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFFD4D4D8),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CREADOR DE IDENTIDAD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF71717A),
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Diseña tu perfil editorial',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ],
                ),
                // Shuffle / Randomize Button
                BouncyTap(
                  onTap: _randomize,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4E4E7), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.casino_outlined, size: 16, color: Color(0xFF18181B)),
                        SizedBox(width: 6),
                        Text(
                          'Aleatorio',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF18181B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Live VOCA Avatar Preview Stage
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE4E4E7), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: VocaAvatar(
                headShape: _head,
                hairStyle: _hair,
                eyesStyle: _eyes,
                mouthStyle: _mouth,
                outfitStyle: _outfit,
                backdropIndex: _backdrop,
                size: 96,
                isAnimated: true,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Name and Daily Goal Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF18181B),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tu nombre...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Goal dropdown pills
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E4E7)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _goal,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF71717A)),
                      items: _goals.map((g) {
                        return DropdownMenuItem(
                          value: g,
                          child: Text(
                            '🎯 $g/día',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18181B),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _goal = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Trait Category Tab Selector
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _sections.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSelected = _currentSection == idx;
                return BouncyTap(
                  onTap: () {
                    VocaHaptics.selection();
                    setState(() => _currentSection = idx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF18181B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE4E4E7),
                      ),
                    ),
                    child: Text(
                      _sections[idx],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF71717A),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Trait Choices Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionContent(),
            ),
          ),

          // Bottom Save Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: VocaButton(
              text: 'GUARDAR IDENTIDAD',
              icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
              isFullWidth: true,
              height: 52,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_currentSection) {
      case 0: // Hair
        return _buildOptionsGrid(
          items: _hairNames,
          selectedIndex: _hair,
          onSelected: (i) => setState(() => _hair = i),
        );
      case 1: // Eyes / Glasses
        return _buildOptionsGrid(
          items: _eyesNames,
          selectedIndex: _eyes,
          onSelected: (i) => setState(() => _eyes = i),
        );
      case 2: // Mouth / Facial Hair
        return _buildOptionsGrid(
          items: _mouthNames,
          selectedIndex: _mouth,
          onSelected: (i) => setState(() => _mouth = i),
        );
      case 3: // Outfit
        return _buildOptionsGrid(
          items: _outfitNames,
          selectedIndex: _outfit,
          onSelected: (i) => setState(() => _outfit = i),
        );
      case 4: // Head Shape
        return _buildOptionsGrid(
          items: _headNames,
          selectedIndex: _head,
          onSelected: (i) => setState(() => _head = i),
        );
      case 5: // Backdrop Color
      default:
        return GridView.builder(
          itemCount: _backdropOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (context, idx) {
            final opt = _backdropOptions[idx];
            final isSelected = _backdrop == idx;
            return BouncyTap(
              onTap: () {
                VocaHaptics.selection();
                setState(() => _backdrop = idx);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: opt['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE4E4E7),
                    width: isSelected ? 2.5 : 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    opt['name'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: idx == 4 ? Colors.white : const Color(0xFF18181B),
                    ),
                  ),
                ),
              ),
            );
          },
        );
    }
  }

  Widget _buildOptionsGrid({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, idx) {
        final isSelected = selectedIndex == idx;
        return BouncyTap(
          onTap: () {
            VocaHaptics.selection();
            onSelected(idx);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF18181B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE4E4E7),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 16,
                  color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    items[idx],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF18181B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

