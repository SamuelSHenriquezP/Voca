import 'package:flutter/material.dart';
import '../../core/theme/voca_colors.dart';
import '../../core/widgets/bouncy_tap.dart';
import '../conversation/screens/conversation_screen.dart';
import '../path/screens/path_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../vault/screens/vault_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const PathScreen(),
      const ConversationScreen(),
      const VaultScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.map_rounded,
                label: 'NIVELES',
                activeColor: const Color(0xFF4F46E5),
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.record_voice_over_rounded,
                label: 'CONVERSAR',
                activeColor: const Color(0xFFE11D48),
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.style_rounded,
                label: 'PALABRAS',
                activeColor: const Color(0xFF0284C7),
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_rounded,
                label: 'PERFIL',
                activeColor: const Color(0xFFD97706),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = _currentIndex == index;

    return BouncyTap(
      onTap: () => _navigateToIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: activeColor.withOpacity(0.4), width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : VocaColors.lockedGray,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

