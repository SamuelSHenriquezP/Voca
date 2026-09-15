import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../widgets/badge_gallery.dart';
import '../widgets/byok_modal.dart';
import '../widgets/stat_grid_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Overview', 'Leaderboard', 'Achievements'];

  final List<Map<String, dynamic>> _rankings = [
    {
      'name': 'David Borg',
      'title': 'C2 • Native Fluency',
      'xp': '2,342 XP',
      'rank': '1',
      'color': const Color(0xFF00C2FF), // Cyan
      'emoji': '🚀',
    },
    {
      'name': 'Lucy Sterling',
      'title': 'C1 • Advanced Speaker',
      'xp': '1,980 XP',
      'rank': '2',
      'color': const Color(0xFFFF7643), // Orange
      'emoji': '🎨',
    },
    {
      'name': 'Jerry West',
      'title': 'B2 • Fluent Conversationalist',
      'xp': '1,720 XP',
      'rank': '3',
      'color': const Color(0xFFFF2D78), // Pink
      'emoji': '⚡',
    },
    {
      'name': 'Alex Rivera (You)',
      'title': 'B1 • Street Conversationalist',
      'xp': '1,450 XP',
      'rank': '4',
      'color': const Color(0xFF6C5CE7), // Purple
      'emoji': '🧑‍🚀',
    },
  ];

  final List<BadgeItem> _badges = const [
    BadgeItem(
      id: 'b1',
      name: '7-Day Fire',
      description: 'Maintained 7 consecutive practice days',
      emoji: '🔥',
      isUnlocked: true,
      unlockDate: 'May 12',
      glowColor: VocaColors.sunOrange,
    ),
    BadgeItem(
      id: 'b2',
      name: 'First Boss Won',
      description: 'Passed Airport Customs spoken simulation',
      emoji: '⚔️',
      isUnlocked: true,
      unlockDate: 'May 14',
      glowColor: VocaColors.accentPink,
    ),
    BadgeItem(
      id: 'b3',
      name: 'Accent Master',
      description: 'Achieved >90% native pronunciation match',
      emoji: '🎯',
      isUnlocked: true,
      unlockDate: 'May 15',
      glowColor: VocaColors.electricCyan,
    ),
    BadgeItem(
      id: 'b4',
      name: 'Voice Marathon',
      description: 'Spoke English for 500+ total minutes',
      emoji: '🎙️',
      isUnlocked: false,
      glowColor: VocaColors.primaryPurple,
    ),
    BadgeItem(
      id: 'b5',
      name: 'Polyglot Ace',
      description: 'Master 1,000 spoken English vocabulary words',
      emoji: '👑',
      isUnlocked: false,
      glowColor: VocaColors.goldXp,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Creative Profile Purple Gradient Header (Image 1 & 2)
            _buildCurvedHeader(context),

            const SizedBox(height: 16),

            // 2. SpaceApp Search Bar (Image 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEFF0F6), width: 2),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search skills, topics, or words...',
                          hintStyle: TextStyle(color: Color(0xFFB0B7C3), fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C33CF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Pill Tabs (Image 2: Designer, Category, Attention)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: BouncyTap(
                      onTap: () => setState(() => _selectedTab = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6C5CE7) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6C5CE7) : const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _tabs[index],
                          style: VocaTypography.buttonText.copyWith(
                            color: isSelected ? Colors.white : const Color(0xFF6B7280),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // 4. SpaceApp 2x2 Vibrant Rounded Storage Cards (Image 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PROGRESS OVERVIEW',
                    style: VocaTypography.heading3.copyWith(
                      fontSize: 14,
                      letterSpacing: 1.1,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    'Realtime Sync',
                    style: VocaTypography.caption.copyWith(
                      color: const Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2x2 Grid with exact SpaceApp colors
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  StatGridCard.buildStreakCard(streak: 14),
                  StatGridCard.buildSpokenAudioCard(minutes: 342),
                  StatGridCard.buildVocabularyCard(words: 850),
                  StatGridCard.buildAccuracyCard(score: 88),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 5. Ranking List (Image 2 Right Screen: David Borg, Lucy, etc.)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WEEKLY LEAGUE RANKING',
                    style: VocaTypography.heading3.copyWith(
                      fontSize: 14,
                      letterSpacing: 1.1,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    'Ruby League',
                    style: VocaTypography.caption.copyWith(
                      color: VocaColors.rubyRed,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _rankings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final user = _rankings[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (user['color'] as Color).withOpacity(0.35),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (user['color'] as Color).withOpacity(0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (user['color'] as Color).withOpacity(0.15),
                        ),
                        child: Center(
                          child: Text(user['emoji'], style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name & Tier
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'],
                              style: VocaTypography.heading3.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user['title'],
                              style: VocaTypography.caption.copyWith(
                                color: const Color(0xFF6B7280),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rank Pill Badge (Image 2 style)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: user['color'] as Color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#${user['rank']} • ${user['xp']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // 6. Achievements Gallery
            BadgeGallery(badges: _badges),

            const SizedBox(height: 24),

            // 7. BYOK Tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BouncyTap(
                onTap: () => ByokModal.show(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3), width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0EEFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.vpn_key_rounded, color: Color(0xFF6C5CE7), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI Voice Engine (BYOK)', style: VocaTypography.heading3.copyWith(fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              'Gemini 1.5 Flash • GPT-4o • Azure Speech',
                              style: VocaTypography.caption.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Curved Gradient Header (Image 1 & 2)
  Widget _buildCurvedHeader(BuildContext context) {
    return ClipPath(
      clipper: CurvedHeaderClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8E2DE2), // Vivid Violet
              Color(0xFF4A00E0), // Deep Indigo
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Bar: Back/Menu & Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
                  ),
                  Text(
                    'Profile',
                    style: VocaTypography.heading2.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  BouncyTap(
                    onTap: () => ByokModal.show(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // User Info Row (Image 2 style)
              Row(
                children: [
                  // Avatar with Glowing Outer Ring
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('👩‍💻', style: TextStyle(fontSize: 42)),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name & Handle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alex Rivera',
                          style: VocaTypography.heading1.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Seattle, USA • B1 Speaker',
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Follow/Edit Pill (Image 2)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Color(0xFF5C33CF),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stats 3-Column Counter (Image 2: 648 Follow, 7 Bucket, 1046 Followers)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('14', 'Day Streak 🔥'),
                    Container(width: 1, height: 26, color: Colors.white.withOpacity(0.2)),
                    _buildStatCol('342m', 'Spoken Time 🎙️'),
                    Container(width: 1, height: 26, color: Colors.white.withOpacity(0.2)),
                    _buildStatCol('850', 'Words Mastered 📚'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Organic curved bottom shape for the top header
class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 36);

    final firstControlPoint = Offset(size.width * 0.5, size.height);
    final firstEndPoint = Offset(size.width, size.height - 36);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
