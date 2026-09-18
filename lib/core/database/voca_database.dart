import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class VocaDatabase {
  static final VocaDatabase instance = VocaDatabase._init();
  static Database? _database;

  VocaDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('voca_master.db');
    return _database!;
  }

  static void initializePlatform() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> _initDB(String filePath) async {
    initializePlatform();
    
    String dbPath;
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      final dbDir = await databaseFactory.getDatabasesPath();
      dbPath = p.join(dbDir, filePath);
    } else {
      dbPath = p.join(await getDatabasesPath(), filePath);
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. User Profile & Global Stats
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        xp INTEGER NOT NULL DEFAULT 0,
        streak INTEGER NOT NULL DEFAULT 1,
        lives INTEGER NOT NULL DEFAULT 5,
        highest_floor INTEGER NOT NULL DEFAULT 1,
        unlocked_topics TEXT NOT NULL,
        collected_cards TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Spaced Repetition Vault Vocabulary
    await db.execute('''
      CREATE TABLE vault_words (
        id TEXT PRIMARY KEY,
        word TEXT NOT NULL UNIQUE,
        phonetic TEXT,
        part_of_speech TEXT,
        definition TEXT,
        example_sentence TEXT,
        category TEXT,
        cefr_level TEXT DEFAULT 'A1',
        tier TEXT DEFAULT 'learning',
        days_until_review INTEGER DEFAULT 1,
        accuracy INTEGER DEFAULT 100,
        review_count INTEGER DEFAULT 0,
        last_reviewed_at TEXT,
        next_review_date TEXT
      )
    ''');

    // 3. Conversation Sessions
    await db.execute('''
      CREATE TABLE conversation_sessions (
        id TEXT PRIMARY KEY,
        scenario_id TEXT NOT NULL,
        scenario_title TEXT NOT NULL,
        persona_name TEXT NOT NULL,
        persona_role TEXT NOT NULL,
        total_turns INTEGER DEFAULT 0,
        average_fluency INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 4. Conversation Messages (Dialogue turns with coaching feedback)
    await db.execute('''
      CREATE TABLE conversation_messages (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        message_text TEXT NOT NULL,
        audio_path TEXT,
        fluency_score INTEGER DEFAULT 0,
        grammar_tip TEXT,
        pronunciation_tip TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES conversation_sessions (id) ON DELETE CASCADE
      )
    ''');

    // 5. Practice & Activity History (for radar/velocity analytics)
    await db.execute('''
      CREATE TABLE activity_logs (
        id TEXT PRIMARY KEY,
        activity_type TEXT NOT NULL,
        duration_minutes REAL NOT NULL,
        xp_earned INTEGER NOT NULL,
        accuracy_score REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Seed default user profile
    await db.insert('user_profile', {
      'id': 'current_user',
      'xp': 0,
      'streak': 1,
      'lives': 5,
      'highest_floor': 1,
      'unlocked_topics': 'a1_01',
      'collected_cards': 'card_strike_1,card_strike_2,card_defend_1,card_defend_2,card_skill_1',
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Seed initial vault words
    final defaultWords = [
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
        'last_reviewed_at': DateTime.now().toIso8601String(),
        'next_review_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'v2',
        'word': 'Ephemeral',
        'phonetic': '/ɪˈfem.ɚ.əl/',
        'part_of_speech': 'adjective',
        'definition': 'Lasting for a very short time; fleeting moment in speech or art.',
        'example_sentence': 'The golden evening light through the terminal was beautifully ephemeral.',
        'category': 'Descriptive',
        'cefr_level': 'C1',
        'tier': 'learning',
        'days_until_review': 2,
        'accuracy': 84,
        'review_count': 2,
        'last_reviewed_at': DateTime.now().toIso8601String(),
        'next_review_date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'v3',
        'word': 'Nuanced',
        'phonetic': '/ˈnuː.ɑːnst/',
        'part_of_speech': 'adjective',
        'definition': 'Characterized by subtle distinctions or variations in tone and argument.',
        'example_sentence': 'He gave a nuanced explanation during the technical interview.',
        'category': 'Professional',
        'cefr_level': 'B2',
        'tier': 'mastered',
        'days_until_review': 7,
        'accuracy': 98,
        'review_count': 9,
        'last_reviewed_at': DateTime.now().toIso8601String(),
        'next_review_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      },
    ];

    for (final word in defaultWords) {
      await db.insert('vault_words', word);
    }
  }

  // --- USER PROFILE METHODS ---
  Future<Map<String, dynamic>> getUserProfile() async {
    final db = await database;
    final results = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: ['current_user'],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    // If not found in DB, insert default row immediately
    final defaultProfile = {
      'id': 'current_user',
      'xp': 0,
      'streak': 1,
      'lives': 5,
      'highest_floor': 1,
      'unlocked_topics': 'a1_01',
      'collected_cards': 'card_strike_1,card_strike_2,card_defend_1,card_defend_2,card_skill_1',
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await db.insert('user_profile', defaultProfile, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (_) {}
    return defaultProfile;
  }

  Future<void> updateProfile({
    int? xp,
    int? streak,
    int? lives,
    int? highestFloor,
    String? unlockedTopics,
    String? collectedCards,
  }) async {
    final db = await database;
    final data = <String, dynamic>{
      'id': 'current_user',
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (xp != null) data['xp'] = xp;
    if (streak != null) data['streak'] = streak;
    if (lives != null) data['lives'] = lives;
    if (highestFloor != null) data['highest_floor'] = highestFloor;
    if (unlockedTopics != null) data['unlocked_topics'] = unlockedTopics;
    if (collectedCards != null) data['collected_cards'] = collectedCards;

    final rows = await db.update(
      'user_profile',
      data,
      where: 'id = ?',
      whereArgs: ['current_user'],
    );
    if (rows == 0) {
      data['xp'] ??= 0;
      data['streak'] ??= 1;
      data['lives'] ??= 5;
      data['highest_floor'] ??= 1;
      data['unlocked_topics'] ??= 'a1_01';
      data['collected_cards'] ??= 'card_strike_1';
      await db.insert('user_profile', data, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // --- VAULT METHODS ---
  Future<List<Map<String, dynamic>>> getVaultWords() async {
    final db = await database;
    return await db.query('vault_words', orderBy: 'days_until_review ASC, word ASC');
  }

  Future<void> insertOrUpdateVaultWord(Map<String, dynamic> word) async {
    final db = await database;
    await db.insert(
      'vault_words',
      word,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteVaultWord(String id) async {
    final db = await database;
    await db.delete('vault_words', where: 'id = ?', whereArgs: [id]);
  }

  // --- CONVERSATION HISTORY METHODS ---
  Future<void> saveConversationSession({
    required String sessionId,
    required String scenarioId,
    required String scenarioTitle,
    required String personaName,
    required String personaRole,
    required int totalTurns,
    required int averageFluency,
  }) async {
    final db = await database;
    await db.insert(
      'conversation_sessions',
      {
        'id': sessionId,
        'scenario_id': scenarioId,
        'scenario_title': scenarioTitle,
        'persona_name': personaName,
        'persona_role': personaRole,
        'total_turns': totalTurns,
        'average_fluency': averageFluency,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveConversationMessage({
    required String id,
    required String sessionId,
    required bool isUser,
    required String messageText,
    String? audioPath,
    int fluencyScore = 0,
    String? grammarTip,
    String? pronunciationTip,
  }) async {
    final db = await database;
    await db.insert(
      'conversation_messages',
      {
        'id': id,
        'session_id': sessionId,
        'is_user': isUser ? 1 : 0,
        'message_text': messageText,
        'audio_path': audioPath,
        'fluency_score': fluencyScore,
        'grammar_tip': grammarTip,
        'pronunciation_tip': pronunciationTip,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRecentConversations({int limit = 20}) async {
    final db = await database;
    return await db.query(
      'conversation_sessions',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getMessagesForSession(String sessionId) async {
    final db = await database;
    return await db.query(
      'conversation_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
  }

  // --- ACTIVITY LOGS METHODS ---
  Future<void> logActivity({
    required String activityType,
    required double durationMinutes,
    required int xpEarned,
    required double accuracyScore,
  }) async {
    final db = await database;
    await db.insert('activity_logs', {
      'id': 'act_${DateTime.now().millisecondsSinceEpoch}',
      'activity_type': activityType,
      'duration_minutes': durationMinutes,
      'xp_earned': xpEarned,
      'accuracy_score': accuracyScore,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getActivityLogs({int limit = 50}) async {
    final db = await database;
    return await db.query(
      'activity_logs',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // --- FACTORY RESET ---
  Future<void> resetAllData() async {
    final db = await database;
    await db.delete('conversation_messages');
    await db.delete('conversation_sessions');
    await db.delete('activity_logs');
    await db.delete('vault_words');
    await db.update('user_profile', {
      'xp': 0,
      'streak': 1,
      'lives': 5,
      'highest_floor': 1,
      'unlocked_topics': 'a1_01',
      'collected_cards': 'card_strike_1,card_strike_2,card_defend_1,card_defend_2,card_skill_1',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
