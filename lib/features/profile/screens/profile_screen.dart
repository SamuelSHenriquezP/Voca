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
      'color': const Color(0xFF0284C7),
      'initials': 'DB',
    },
    {
      'name': 'Lucy Sterling',
      'title': 'C1 • Advanced Speaker',
      'xp': '1,980 XP',
      'rank': '2',
      'color': const Color(0xFFD97706),
      'initials': 'LS',
    },
    {
      'name': 'Jerry West',
      'title': 'B2 • Fluent Conversationalist',
      'xp': '1,720 XP',
      'rank': '3',
      'color': const Color(0xFFE11D48),
      'initials': 'JW',
    },
    {
      'name': 'Alex Rivera (You)',
      'title': 'B1 • Street Conversationalist',
      'xp': '1,450 XP',
      'rank': '4',
      'color': const Color(0xFF4F46E5),
      'initials': 'AR',
    },
  ];

  final List<BadgeItem> _badges = const [
    BadgeItem(
      id: 'b1',
      name: '7-Day Streak',
      description: 'Maintained 7 consecutive practice days',
      icon: Icons.local_fire_department_rounded,
      isUnlocked: true,
      unlockDate: 'May 12',
      accentColor: Color(0xFFD97706),
    ),
    BadgeItem(
      id: 'b2',
      name: 'Customs Clear',
      description: 'Passed Airport Customs spoken simulation',
      icon: Icons.shield_outlined,
      isUnlocked: true,
      unlockDate: 'May 14',
      accentColor: Color(0xFF4F46E5),
    ),
    BadgeItem(
      id: 'b3',
      name: 'Accent Precision',
      description: 'Achieved >90% native pronunciation match',
      icon: Icons.center_focus_strong_rounded,
      isUnlocked: true,
      unlockDate: 'May 15',
      accentColor: Color(0xFF0284C7),
    ),
    BadgeItem(
      id: 'b4',
      name: 'Spoken Hours',
      description: 'Spoke English for 500+ total minutes',
      icon: Icons.mic_none_rounded,
      isUnlocked: false,
      accentColor: Color(0xFF059669),
    ),
    BadgeItem(
      id: 'b5',
      name: 'Polyglot Core',
      description: 'Master 1,000 spoken English vocabulary words',
      icon: Icons.workspace_premium_rounded,
      isUnlocked: false,
      accentColor: Color(0xFFB45309),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Editorial Minimalist Header (Obsidian Slate)
            _buildMinimalistHeader(context),

            const SizedBox(height: 16),

            // 2. Minimalist Pill Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: BouncyTap(
                      onTap: () => setState(() => _selectedTab = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Metric Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'METRICS & MASTERY',
                style: VocaTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: VocaColors.darkSlate,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.94,
                children: [
                  StatGridCard.buildStreakCard(streak: 14),
                  StatGridCard.buildSpokenAudioCard(minutes: 342),
                  StatGridCard.buildVocabularyCard(words: 850),
                  StatGridCard.buildAccuracyCard(score: 88),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 4. Weekly League Ranking (Clean Minimalist Rows)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WEEKLY LEADERBOARD',
                    style: VocaTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: VocaColors.darkSlate,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    'Division I',
                    style: VocaTypography.caption.copyWith(
                      color: const Color(0xFF4F46E5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _rankings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = _rankings[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Monogram Avatar
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF1F5F9),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                        ),
                        child: Center(
                          child: Text(
                            user['initials'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name & Tier
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              user['title'],
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rank Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                        ),
                        child: Text(
                          '#${user['rank']} • ${user['xp']}',
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 5. Achievements Gallery
            BadgeGallery(badges: _badges),

            const SizedBox(height: 24),

            // 6. Settings & BYOK
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BouncyTap(
                onTap: () => ByokModal.show(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.key_rounded, color: Color(0xFF4F46E5), size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Voice Engine (BYOK)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Google Gemini 1.5, OpenAI GPT-4o, Azure Voice',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
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

  // Minimalist Obsidian Header
  Widget _buildMinimalistHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Obsidian
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PROFILE',
                  style: VocaTypography.caption.copyWith(
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                BouncyTap(
                  onTap: () => ByokModal.show(context),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155), width: 1),
                    ),
                    child: const Icon(Icons.settings_outlined, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // User Info
            Row(
              children: [
                // Minimalist Avatar
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4F46E5),
                    border: Border.all(color: const Color(0xFF312E81), width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'AR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alex Rivera',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'B1 Conversationalist • Seattle, USA',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Stats Mini-Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF334155), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHeaderMetric('14', 'DAYS STREAK'),
                  Container(width: 1, height: 22, color: const Color(0xFF334155)),
                  _buildHeaderMetric('342m', 'SPOKEN TIME'),
                  Container(width: 1, height: 22, color: const Color(0xFF334155)),
                  _buildHeaderMetric('850', 'WORDS'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
