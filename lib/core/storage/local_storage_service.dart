import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> init() async {
    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        debugPrint('SharedPreferences init notice: $e');
      }
    }
  }

  // XP
  int getXp() => _prefs?.getInt(_kXp) ?? 0;
  Future<void> addXp(int amount) async {
    final current = getXp();
    await _prefs?.setInt(_kXp, current + amount);
  }

  // Streak
  int getStreak() => _prefs?.getInt(_kStreak) ?? 1;
  Future<void> setStreak(int streak) async {
    await _prefs?.setInt(_kStreak, streak);
  }

  // Lives
  int getLives() => _prefs?.getInt(_kLives) ?? 5;
  Future<void> setLives(int lives) async {
    await _prefs?.setInt(_kLives, lives);
  }

  // Highest Floor in Roguelike
  int getHighestFloor() => _prefs?.getInt(_kHighestFloor) ?? 1;
  Future<void> recordFloorReached(int floor) async {
    final current = getHighestFloor();
    if (floor > current) {
      await _prefs?.setInt(_kHighestFloor, floor);
    }
  }

  // Unlocked Topics
  List<String> getUnlockedTopicIds() {
    final raw = _prefs?.getStringList(_kUnlockedTopics);
    if (raw == null || raw.isEmpty) {
      return ['a1_01']; // First topic unlocked by default
    }
    return raw;
  }

  Future<void> unlockTopic(String topicId) async {
    final list = getUnlockedTopicIds();
    if (!list.contains(topicId)) {
      list.add(topicId);
      await _prefs?.setStringList(_kUnlockedTopics, list);
    }
  }

  // Collected Cards for Roguelike & Vault
  List<String> getCollectedCardIds() {
    return _prefs?.getStringList(_kCollectedCards) ??
        ['card_strike_1', 'card_strike_2', 'card_defend_1', 'card_defend_2', 'card_skill_1'];
  }

  Future<void> saveCollectedCard(String cardId) async {
    final list = getCollectedCardIds();
    if (!list.contains(cardId)) {
      list.add(cardId);
      await _prefs?.setStringList(_kCollectedCards, list);
    }
  }

  // Vault Spaced Repetition Words
  List<Map<String, dynamic>> getVaultWords() {
    final raw = _prefs?.getString(_kVaultWords);
    if (raw == null || raw.isEmpty) {
      return _defaultVaultWords;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return _defaultVaultWords;
    }
  }

  Future<void> addWordToVault({
    required String word,
    required String phonetic,
    required String partOfSpeech,
    required String definition,
    required String exampleSentence,
    required String category,
  }) async {
    final words = getVaultWords();
    final exists = words.any((w) => w['word'].toString().toLowerCase() == word.toLowerCase());
    if (!exists) {
      words.insert(0, {
        'id': 'vault_${DateTime.now().millisecondsSinceEpoch}',
        'word': word,
        'phonetic': phonetic,
        'partOfSpeech': partOfSpeech,
        'definition': definition,
        'exampleSentence': exampleSentence,
        'category': category,
        'tier': 'learning',
        'daysUntilReview': 1,
        'accuracy': 100,
      });
      await _prefs?.setString(_kVaultWords, jsonEncode(words));
    }
  }

  Future<void> saveVaultWords(List<Map<String, dynamic>> words) async {
    await _prefs?.setString(_kVaultWords, jsonEncode(words));
  }

  // Reset progress from 0 (satisfies clean restart)
  Future<void> resetAll() async {
    await _prefs?.clear();
  }

  static const List<Map<String, dynamic>> _defaultVaultWords = [
    {
      'id': 'v1',
      'word': 'Understated',
      'phonetic': '/ˌʌn.dɚˈsteɪ.t̬ɪd/',
      'partOfSpeech': 'adjective',
      'definition': 'Not attracting attention; subtle, sophisticated and restrained.',
      'exampleSentence': 'Her architectural design was wonderfully understated yet deeply functional.',
      'category': 'Social',
      'tier': 'review',
      'daysUntilReview': 1,
      'accuracy': 91,
    },
    {
      'id': 'v2',
      'word': 'Complimentary',
      'phonetic': '/ˌkɑːm.pləˈmen.t̬ɚ.i/',
      'partOfSpeech': 'adjective',
      'definition': 'Praising or approving; given free of charge as a courtesy.',
      'exampleSentence': 'The boutique hotel offered a complimentary espresso upon check-in.',
      'category': 'Travel',
      'tier': 'learning',
      'daysUntilReview': 3,
      'accuracy': 88,
    },
    {
      'id': 'v3',
      'word': 'Concur',
      'phonetic': '/kənˈkɝː/',
      'partOfSpeech': 'verb',
      'definition': 'To be of the same opinion; to agree with a proposed direction.',
      'exampleSentence': 'I fully concur with your assessment regarding the quarterly deliverables.',
      'category': 'Workplace',
      'tier': 'mastered',
      'daysUntilReview': 7,
      'accuracy': 96,
    },
  ];
}
