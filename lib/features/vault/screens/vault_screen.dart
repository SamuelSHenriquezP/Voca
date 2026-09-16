import 'package:flutter/material.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../models/vocabulary_word.dart';
import '../widgets/flashcard_card.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  int _selectedCategoryIndex = 0;
  bool _isFlashcardMode = true;
  int _currentCardIndex = 0;
  String _searchQuery = '';

  final List<String> _categories = const [
    'All',
    'Dining',
    'Travel',
    'Workplace',
    'Social',
  ];

  late List<VocabularyWord> _words;

  @override
  void initState() {
    super.initState();
    _words = [
      const VocabularyWord(
        id: 'v1',
        word: 'Understated',
        phonetic: '/ˌʌn.dɚˈsteɪ.t̬ɪd/',
        partOfSpeech: 'adjective',
        definition: 'Not attracting attention; subtle, sophisticated and restrained.',
        exampleSentence: 'Her architectural design was wonderfully understated yet deeply functional.',
        category: 'Social',
        tier: MasteryTier.review,
        daysUntilReview: 1,
        accuracy: 91,
      ),
      const VocabularyWord(
        id: 'v2',
        word: 'Complimentary',
        phonetic: '/ˌkɑːm.pləˈmen.t̬ɚ.i/',
        partOfSpeech: 'adjective',
        definition: 'Praising or approving; given free of charge as a courtesy.',
        exampleSentence: 'The boutique hotel offered a complimentary espresso upon check-in.',
        category: 'Travel',
        tier: MasteryTier.learning,
        daysUntilReview: 3,
        accuracy: 88,
      ),
      const VocabularyWord(
        id: 'v3',
        word: 'Concur',
        phonetic: '/kənˈkɝː/',
        partOfSpeech: 'verb',
        definition: 'To be of the same opinion; to agree with a proposed direction.',
        exampleSentence: 'I fully concur with your assessment regarding the quarterly deliverables.',
        category: 'Workplace',
        tier: MasteryTier.mastered,
        daysUntilReview: 7,
        accuracy: 96,
      ),
      const VocabularyWord(
        id: 'v4',
        word: 'Sparkling',
        phonetic: '/ˈspɑːr.klɪŋ/',
        partOfSpeech: 'adjective',
        definition: 'Shining with bright points of light; effervescent (carbonated).',
        exampleSentence: 'Would you prefer still or sparkling water with your main course?',
        category: 'Dining',
        tier: MasteryTier.mastered,
        daysUntilReview: 14,
        accuracy: 95,
      ),
      const VocabularyWord(
        id: 'v5',
        word: 'Layover',
        phonetic: '/ˈleɪˌoʊ.vɚ/',
        partOfSpeech: 'noun',
        definition: 'A period of rest or waiting before a further stage in a journey.',
        exampleSentence: 'We have a three-hour layover at Tokyo Haneda before our onward flight.',
        category: 'Travel',
        tier: MasteryTier.learning,
        daysUntilReview: 2,
        accuracy: 84,
      ),
      const VocabularyWord(
        id: 'v6',
        word: 'Appetizer',
        phonetic: '/ˈæp.ə.taɪ.zɚ/',
        partOfSpeech: 'noun',
        definition: 'A small dish of food served before the main course of a meal.',
        exampleSentence: 'We ordered the smoked salmon crostini as a shared appetizer.',
        category: 'Dining',
        tier: MasteryTier.review,
        daysUntilReview: 1,
        accuracy: 89,
      ),
    ];
  }

  List<VocabularyWord> get _filteredWords {
    return _words.where((w) {
      final matchesCategory = _selectedCategoryIndex == 0 ||
          w.category.toLowerCase() == _categories[_selectedCategoryIndex].toLowerCase();
      final matchesQuery = _searchQuery.isEmpty ||
          w.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.definition.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _handleRateWord(VocabularyWord word, MasteryTier newTier) {
    setState(() {
      final idx = _words.indexWhere((w) => w.id == word.id);
      if (idx != -1) {
        _words[idx] = word.copyWith(
          tier: newTier,
          daysUntilReview: newTier == MasteryTier.review
              ? 1
              : (newTier == MasteryTier.learning ? 3 : 7),
        );
      }
      if (_currentCardIndex < _filteredWords.length - 1) {
        _currentCardIndex++;
      } else {
        _currentCardIndex = 0;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mastery updated: ${word.word} scheduled.'),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredWords;
    final reviewCount = _words.where((w) => w.tier == MasteryTier.review).length;
    final learningCount = _words.where((w) => w.tier == MasteryTier.learning).length;
    final masteredCount = _words.where((w) => w.tier == MasteryTier.mastered).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      body: Column(
        children: [
          // 1. Obsidian Header with Metrics & Mode Toggle
          _buildVaultHeader(reviewCount, learningCount, masteredCount),

          // 2. Search & Category Filters
          _buildSearchAndFilters(),

          // 3. Main Vault Content (Flashcard Mode vs List Mode)
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : (_isFlashcardMode
                    ? _buildFlashcardView(filtered)
                    : _buildListView(filtered)),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultHeader(int review, int learning, int mastered) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VOCABULARY VAULT',
                      style: VocaTypography.caption.copyWith(
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Active Spaced Repetition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                // Mode Toggle (Flashcards / List)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155), width: 1),
                  ),
                  child: Row(
                    children: [
                      BouncyTap(
                        onTap: () {
                          VocaHaptics.light();
                          setState(() => _isFlashcardMode = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isFlashcardMode ? const Color(0xFF4F46E5) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.style_rounded,
                            size: 16,
                            color: _isFlashcardMode ? Colors.white : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      BouncyTap(
                        onTap: () {
                          VocaHaptics.light();
                          setState(() => _isFlashcardMode = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: !_isFlashcardMode ? const Color(0xFF4F46E5) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.view_list_rounded,
                            size: 16,
                            color: !_isFlashcardMode ? Colors.white : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tier Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildTierSummary(
                    count: '$review',
                    label: 'REVIEW DUE',
                    color: const Color(0xFFE11D48),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTierSummary(
                    count: '$learning',
                    label: 'LEARNING',
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTierSummary(
                    count: '$mastered',
                    label: 'MASTERED',
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierSummary({
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: [
          // Search Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _currentCardIndex = 0;
                });
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                hintText: 'Search vocabulary or definition...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Categories Horizontal Scroll
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return BouncyTap(
                  onTap: () {
                    VocaHaptics.selection();
                    setState(() {
                      _selectedCategoryIndex = index;
                      _currentCardIndex = 0;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Flashcard Deck View
  Widget _buildFlashcardView(List<VocabularyWord> words) {
    final validIndex = _currentCardIndex.clamp(0, words.length - 1);
    final activeWord = words[validIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Counter indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CARD ${validIndex + 1} OF ${words.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Color(0xFF64748B),
                ),
              ),
              Row(
                children: [
                  BouncyTap(
                    onTap: () {
                      if (validIndex > 0) {
                        setState(() => _currentCardIndex--);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Color(0xFF334155)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BouncyTap(
                    onTap: () {
                      if (validIndex < words.length - 1) {
                        setState(() => _currentCardIndex++);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Interactive 3D Card
          FlashcardCard(
            key: ValueKey(activeWord.id),
            word: activeWord,
            onRate: (tier) => _handleRateWord(activeWord, tier),
          ),
        ],
      ),
    );
  }

  // List View Mode
  Widget _buildListView(List<VocabularyWord> words) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
      itemCount: words.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final word = words[index];
        final tierColor = word.tier == MasteryTier.review
            ? const Color(0xFFE11D48)
            : (word.tier == MasteryTier.learning
                ? const Color(0xFF0284C7)
                : const Color(0xFF059669));

        final tierLabel = word.tier == MasteryTier.review
            ? 'Review Due'
            : (word.tier == MasteryTier.learning ? 'Learning' : 'Mastered');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Row(
            children: [
              // Play Audio Button
              BouncyTap(
                onTap: () {
                  VocaHaptics.selection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Playing audio: "${word.word}" ${word.phonetic}'),
                      backgroundColor: const Color(0xFF0F172A),
                      duration: const Duration(milliseconds: 1000),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.volume_up_rounded, color: Color(0xFF4F46E5), size: 18),
                ),
              ),
              const SizedBox(width: 14),

              // Word & Phonetic
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          word.word,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          word.phonetic,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      word.definition,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Tier Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tierColor.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  tierLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: tierColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
          SizedBox(height: 12),
          Text(
            'No matching words found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
