import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/voca_database.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _kXp = 'voca_xp';
  static const String _kStreak = 'voca_streak';
  static const String _kLives = 'voca_lives';
  static const String _kUnlockedTopics = 'voca_unlocked_topics';
  static const String _kCollectedCards = 'voca_collected_cards';
  static const String _kVaultWords = 'voca_vault_words';
  static const String _kHighestFloor = 'voca_highest_floor';

  SharedPreferences? _prefs;
  final VocaDatabase _db = VocaDatabase.instance;

  // In-memory cache for 0ms synchronous UI reads
  int _cachedXp = 0;
  int _cachedStreak = 1;
  int _cachedLives = 5;
  int _cachedHighestFloor = 1;
  List<String> _cachedUnlockedTopics = ['a1_01'];
  List<String> _cachedCollectedCards = [
    'card_strike_1',
    'card_strike_2',
    'card_defend_1',
    'card_defend_2',
    'card_skill_1',
  ];
  List<Map<String, dynamic>> _cachedVaultWords = [];

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('SharedPreferences init notice: $e');
    }

    try {
      // Initialize SQLite database
      await _db.database;

      // Sync user profile from SQLite
      final profile = await _db.getUserProfile();
      _cachedXp = profile['xp'] as int? ?? _prefs?.getInt(_kXp) ?? 0;
      _cachedStreak = profile['streak'] as int? ?? _prefs?.getInt(_kStreak) ?? 1;
      _cachedLives = profile['lives'] as int? ?? _prefs?.getInt(_kLives) ?? 5;
      _cachedHighestFloor = profile['highest_floor'] as int? ?? _prefs?.getInt(_kHighestFloor) ?? 1;

      final topicsStr = profile['unlocked_topics'] as String?;
      if (topicsStr != null && topicsStr.isNotEmpty) {
        _cachedUnlockedTopics = topicsStr.split(',').where((s) => s.isNotEmpty).toList();
      } else {
        _cachedUnlockedTopics = _prefs?.getStringList(_kUnlockedTopics) ?? ['a1_01'];
      }

      final cardsStr = profile['collected_cards'] as String?;
      if (cardsStr != null && cardsStr.isNotEmpty) {
        _cachedCollectedCards = cardsStr.split(',').where((s) => s.isNotEmpty).toList();
      } else {
        _cachedCollectedCards = _prefs?.getStringList(_kCollectedCards) ?? [
          'card_strike_1',
          'card_strike_2',
          'card_defend_1',
          'card_defend_2',
          'card_skill_1',
        ];
      }

      // Sync vault words from SQLite
      final dbVault = await _db.getVaultWords();
      if (dbVault.isNotEmpty) {
        _cachedVaultWords = dbVault.map((row) => Map<String, dynamic>.from(row)).toList();
      } else {
        _cachedVaultWords = _loadPrefsVaultWords();
        // Persist default words into SQLite
        for (final w in _cachedVaultWords) {
          await _db.insertOrUpdateVaultWord(w);
        }
      }
    } catch (e) {
      debugPrint('SQLite init notice (using memory/prefs fallback): $e');
      _cachedXp = _prefs?.getInt(_kXp) ?? 0;
      _cachedStreak = _prefs?.getInt(_kStreak) ?? 1;
      _cachedLives = _prefs?.getInt(_kLives) ?? 5;
      _cachedHighestFloor = _prefs?.getInt(_kHighestFloor) ?? 1;
      _cachedUnlockedTopics = _prefs?.getStringList(_kUnlockedTopics) ?? ['a1_01'];
      _cachedCollectedCards = _prefs?.getStringList(_kCollectedCards) ?? [
        'card_strike_1',
        'card_strike_2',
        'card_defend_1',
        'card_defend_2',
        'card_skill_1',
      ];
      _cachedVaultWords = _loadPrefsVaultWords();
    }
  }

  // --- XP ---
  int getXp() => _cachedXp;

  Future<void> addXp(int amount) async {
    _cachedXp += amount;
    await _prefs?.setInt(_kXp, _cachedXp);
    try {
      await _db.updateProfile(xp: _cachedXp);
    } catch (_) {}
  }

  // --- STREAK ---
  int getStreak() => _cachedStreak;

  Future<void> setStreak(int streak) async {
    _cachedStreak = streak;
    await _prefs?.setInt(_kStreak, streak);
    try {
      await _db.updateProfile(streak: streak);
    } catch (_) {}
  }

  // --- LIVES ---
  int getLives() => _cachedLives;

  Future<void> setLives(int lives) async {
    _cachedLives = lives;
    await _prefs?.setInt(_kLives, lives);
    try {
      await _db.updateProfile(lives: lives);
    } catch (_) {}
  }

  // --- HIGHEST FLOOR ---
  int getHighestFloor() => _cachedHighestFloor;

  Future<void> recordFloorReached(int floor) async {
    if (floor > _cachedHighestFloor) {
      _cachedHighestFloor = floor;
      await _prefs?.setInt(_kHighestFloor, floor);
      try {
        await _db.updateProfile(highestFloor: floor);
      } catch (_) {}
    }
  }

  // --- UNLOCKED TOPICS ---
  List<String> getUnlockedTopicIds() => List.unmodifiable(_cachedUnlockedTopics);

  Future<void> unlockTopic(String topicId) async {
    if (!_cachedUnlockedTopics.contains(topicId)) {
      _cachedUnlockedTopics.add(topicId);
      await _prefs?.setStringList(_kUnlockedTopics, _cachedUnlockedTopics);
      try {
        await _db.updateProfile(unlockedTopics: _cachedUnlockedTopics.join(','));
      } catch (_) {}
    }
  }

  // --- COLLECTED CARDS ---
  List<String> getCollectedCardIds() => List.unmodifiable(_cachedCollectedCards);

  Future<void> saveCollectedCard(String cardId) async {
    if (!_cachedCollectedCards.contains(cardId)) {
      _cachedCollectedCards.add(cardId);
      await _prefs?.setStringList(_kCollectedCards, _cachedCollectedCards);
      try {
        await _db.updateProfile(collectedCards: _cachedCollectedCards.join(','));
      } catch (_) {}
    }
  }

  // --- VAULT WORDS ---
  List<Map<String, dynamic>> getVaultWords() => List.unmodifiable(_cachedVaultWords);

  Future<void> addWordToVault({
    required String word,
    required String phonetic,
    required String partOfSpeech,
    required String definition,
    required String exampleSentence,
    required String category,
    String cefrLevel = 'B1',
  }) async {
    final exists = _cachedVaultWords.any(
      (w) => w['word'].toString().toLowerCase() == word.toLowerCase(),
    );
    if (!exists) {
      final newWord = {
        'id': 'vault_${DateTime.now().millisecondsSinceEpoch}',
        'word': word,
        'phonetic': phonetic,
        'part_of_speech': partOfSpeech,
        'definition': definition,
        'example_sentence': exampleSentence,
        'category': category,
        'cefr_level': cefrLevel,
        'tier': 'learning',
        'days_until_review': 1,
        'accuracy': 100,
        'review_count': 0,
        'last_reviewed_at': DateTime.now().toIso8601String(),
        'next_review_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      };
      _cachedVaultWords.insert(0, newWord);
      await _prefs?.setString(_kVaultWords, jsonEncode(_cachedVaultWords));
      try {
        await _db.insertOrUpdateVaultWord(newWord);
      } catch (_) {}
    }
  }

  Future<void> saveVaultWords(List<Map<String, dynamic>> words) async {
    _cachedVaultWords = List.from(words);
    await _prefs?.setString(_kVaultWords, jsonEncode(_cachedVaultWords));
    try {
      for (final w in words) {
        await _db.insertOrUpdateVaultWord(w);
      }
    } catch (_) {}
  }

  // --- CONVERSATION SESSIONS (SQLITE) ---
  Future<void> saveConversationHistory({
    required String sessionId,
    required String scenarioId,
    required String scenarioTitle,
    required String personaName,
    required String personaRole,
    required int totalTurns,
    required int averageFluency,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      await _db.saveConversationSession(
        sessionId: sessionId,
        scenarioId: scenarioId,
        scenarioTitle: scenarioTitle,
        personaName: personaName,
        personaRole: personaRole,
        totalTurns: totalTurns,
        averageFluency: averageFluency,
      );

      for (final msg in messages) {
        await _db.saveConversationMessage(
          id: msg['id'] as String? ?? 'msg_${DateTime.now().microsecondsSinceEpoch}',
          sessionId: sessionId,
          isUser: msg['isUser'] as bool? ?? false,
          messageText: msg['text'] as String? ?? '',
          audioPath: msg['audioPath'] as String?,
          fluencyScore: msg['fluencyScore'] as int? ?? 0,
          grammarTip: msg['grammarTip'] as String?,
          pronunciationTip: msg['pronunciationTip'] as String?,
        );
      }
    } catch (e) {
      debugPrint('Failed to save conversation history in SQLite: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentConversations({int limit = 20}) async {
    try {
      return await _db.getRecentConversations(limit: limit);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getConversationMessages(String sessionId) async {
    try {
      return await _db.getMessagesForSession(sessionId);
    } catch (_) {
      return [];
    }
  }

  // --- ACTIVITY LOGS (SQLITE) ---
  Future<void> logPracticeActivity({
    required String activityType,
    required double durationMinutes,
    required int xpEarned,
    required double accuracyScore,
  }) async {
    try {
      await _db.logActivity(
        activityType: activityType,
        durationMinutes: durationMinutes,
        xpEarned: xpEarned,
        accuracyScore: accuracyScore,
      );
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getActivityLogs({int limit = 50}) async {
    try {
      return await _db.getActivityLogs(limit: limit);
    } catch (_) {
      return [];
    }
  }

  // --- RESET ALL DATA ---
  Future<void> resetAll() async {
    _cachedXp = 0;
    _cachedStreak = 1;
    _cachedLives = 5;
    _cachedHighestFloor = 1;
    _cachedUnlockedTopics = ['a1_01'];
    _cachedCollectedCards = [
      'card_strike_1',
      'card_strike_2',
      'card_defend_1',
      'card_defend_2',
      'card_skill_1',
    ];
    _cachedVaultWords = List.from(_defaultVaultWords);

    await _prefs?.clear();
    try {
      await _db.resetAllData();
    } catch (_) {}
  }

  List<Map<String, dynamic>> _loadPrefsVaultWords() {
    final raw = _prefs?.getString(_kVaultWords);
    if (raw == null || raw.isEmpty) {
      return List.from(_defaultVaultWords);
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return List.from(_defaultVaultWords);
    }
  }

  static const List<Map<String, dynamic>> _defaultVaultWords = [
    {
      'id': 'v1',
      'word': 'Understated',
      'phonetic': '/ˌʌn.dɚˈsteɪ.t̬ɪd/',
      'part_of_speech': 'adjective',
      'definition': 'Not attracting attention; subtle, sophisticated and restrained.',
      'example_sentence': 'Her architectural design was wonderfully understated yet deeply functional.',
      'category': 'Social',
      'cefr_level': 'B2',
      'tier': 'review',
      'days_until_review': 1,
      'accuracy': 91,
      'review_count': 4,
    },
    {
      'id': 'v2',
      'word': 'Complimentary',
      'phonetic': '/ˌkɑːm.pləˈmen.t̬ɚ.i/',
      'part_of_speech': 'adjective',
      'definition': 'Praising or approving; given free of charge as a courtesy.',
      'example_sentence': 'The boutique hotel offered a complimentary espresso upon check-in.',
      'category': 'Travel',
      'cefr_level': 'B1',
      'tier': 'learning',
      'days_until_review': 3,
      'accuracy': 88,
      'review_count': 2,
    },
    {
      'id': 'v3',
      'word': 'Concur',
      'phonetic': '/kənˈkɝː/',
      'part_of_speech': 'verb',
      'definition': 'To be of the same opinion; to agree with a proposed direction.',
      'example_sentence': 'I fully concur with your assessment regarding the quarterly deliverables.',
      'category': 'Workplace',
      'cefr_level': 'B2',
      'tier': 'mastered',
      'days_until_review': 7,
      'accuracy': 96,
      'review_count': 9,
    },
  ];
}
