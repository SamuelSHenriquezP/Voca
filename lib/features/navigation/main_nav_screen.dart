import 'package:flutter/material.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../conversation/screens/conversation_screen.dart';
import '../path/screens/path_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../roguelike/screens/expedition_map_screen.dart';

/// Minimalist, non-intrusive navigation framework for VOCA.
/// Preserves state across tabs with an ultra-clean monochrome editorial bottom dock.
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PathScreen(),
    ExpeditionMapScreen(),
    ConversationScreen(),
    ProfileScreen(),
  ];

  final List<Map<String, dynamic>> _tabs = const [
    {
      'label': 'Syllabus',
      'icon': Icons.auto_stories_outlined,
      'activeIcon': Icons.auto_stories_rounded,
    },
    {
      'label': 'Expedición',
      'icon': Icons.explore_outlined,
      'activeIcon': Icons.explore_rounded,
    },
    {
      'label': 'Conversación',
      'icon': Icons.forum_outlined,
      'activeIcon': Icons.forum_rounded,
    },
    {
      'label': 'Perfil',
      'icon': Icons.person_outline_rounded,
      'activeIcon': Icons.person_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 62,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _currentIndex == index;
              final tab = _tabs[index];

              return Expanded(
                child: BouncyTap(
                  onTap: () {
                    if (_currentIndex != index) {
                      VocaHaptics.selection();
                      setState(() => _currentIndex = index);
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? (tab['activeIcon'] as IconData)
                              : (tab['icon'] as IconData),
                          size: 21,
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 3.5,
                          height: 3.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
