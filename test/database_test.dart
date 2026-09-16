import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:voca_app/core/database/voca_database.dart';
import 'package:voca_app/core/storage/local_storage_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('VocaDatabase initializes and stores conversation history', () async {
    final db = VocaDatabase.instance;
    final profile = await db.getUserProfile();
    expect(profile, isNotEmpty);
    expect(profile['lives'], equals(5));

    final sessionId = 'test_session_${DateTime.now().millisecondsSinceEpoch}';
    await db.saveConversationSession(
      sessionId: sessionId,
      scenarioId: 'jfk_customs',
      scenarioTitle: 'JFK Customs Inspection',
      personaName: 'Officer Miller',
      personaRole: 'Customs Officer',
      totalTurns: 2,
      averageFluency: 95,
    );

    await db.saveConversationMessage(
      id: 'msg_1',
      sessionId: sessionId,
      isUser: true,
      messageText: 'I will be staying for two weeks.',
      fluencyScore: 95,
      grammarTip: 'Good future tense',
      pronunciationTip: 'Clear stress',
    );

    final sessions = await db.getRecentConversations();
    expect(sessions.any((s) => s['id'] == sessionId), isTrue);

    final messages = await db.getMessagesForSession(sessionId);
    expect(messages.length, equals(1));
    expect(messages.first['message_text'], equals('I will be staying for two weeks.'));
  });

  test('LocalStorageService in-memory and database sync works', () async {
    final storage = LocalStorageService();
    await storage.init();

    final initialXp = storage.getXp();
    await storage.addXp(50);
    expect(storage.getXp(), equals(initialXp + 50));

    final initialStreak = storage.getStreak();
    await storage.setStreak(initialStreak + 1);
    expect(storage.getStreak(), equals(initialStreak + 1));

    final words = storage.getVaultWords();
    expect(words.isNotEmpty, isTrue);
  });
}
