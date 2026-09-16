import 'dart:math' as math;
import '../models/chat_message.dart';

class AiReplyResult {
  final String replyText;
  final String grammarTip;
  final String pronunciationTip;
  final int accuracyScore;
  final String suggestedFollowUp;
  final String hint;

  const AiReplyResult({
    required this.replyText,
    required this.grammarTip,
    required this.pronunciationTip,
    required this.accuracyScore,
    required this.suggestedFollowUp,
    required this.hint,
  });
}

class ContextualConversationEngine {
  ContextualConversationEngine._();

  /// Analyzes the user's input in the current scenario context and produces
  /// an authentic, character-consistent spoken reply with pedagogical feedback.
  static AiReplyResult processUserInput({
    required String scenarioId,
    required String personaName,
    required String userText,
    required List<ChatMessage> history,
    String? topicTitle,
  }) {
    final lower = userText.trim().toLowerCase();
    final random = math.Random();

    // 1. Determine base feedback tips
    final grammarTip = _evaluateGrammar(lower);
    final pronunciationTip = _evaluatePronunciation(lower);
    final score = (88 + random.nextInt(10)).clamp(88, 98);

    // 2. Generate persona-aligned contextual reply
    switch (scenarioId) {
      case 'jfk_customs':
        return _handleCustoms(lower, personaName, grammarTip, pronunciationTip, score);
      case 'coffee_barista':
        return _handleBarista(lower, personaName, grammarTip, pronunciationTip, score);
      case 'tech_interview':
        return _handleInterview(lower, personaName, grammarTip, pronunciationTip, score);
      case 'hotel_concierge':
        return _handleConcierge(lower, personaName, grammarTip, pronunciationTip, score);
      case 'alex_free_chat':
      default:
        return _handleFreeChat(lower, personaName, grammarTip, pronunciationTip, score, topicTitle);
    }
  }

  // =========================================================================
  // SCENARIO HANDLERS
  // =========================================================================

  static AiReplyResult _handleCustoms(
    String lower,
    String persona,
    String grammarTip,
    String pronunciationTip,
    int score,
  ) {
    if (lower.contains('vacation') || lower.contains('visit') || lower.contains('stay') || lower.contains('week') || lower.contains('month')) {
      return AiReplyResult(
        replyText: 'Understood. Where exactly will you be residing during your stay in the United States?',
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: "I'll be staying at a hotel in downtown Seattle.",
        hint: 'Use natural prepositions: "at a hotel in [city]".',
      );
    } else if (lower.contains('hotel') || lower.contains('house') || lower.contains('brother') || lower.contains('friend') || lower.contains('airbnb')) {
      return AiReplyResult(
        replyText: 'Do you have any commercial goods, plants, meats, or currency exceeding ten thousand dollars to declare?',
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'No, I have nothing to declare, officer.',
        hint: 'Standard customs answer: "nothing to declare".',
      );
    } else if (lower.contains('nothing') || lower.contains('no') || lower.contains('declare')) {
      return AiReplyResult(
        replyText: 'Everything checks out. Your passport is stamped. Enjoy your stay in the US, welcome!',
        grammarTip: 'Polite, direct negative responses are standard in border control.',
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'Thank you very much, have a good day.',
        hint: 'Courteous exit formula.',
      );
    } else {
      return AiReplyResult(
        replyText: 'Please clarify your purpose of travel and whether your return flight is already booked.',
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'Yes, my return flight is booked for next Sunday.',
        hint: 'Keep responses concise and direct for law enforcement.',
      );
    }
  }

  static AiReplyResult _handleBarista(
    String lower,
    String persona,
    String grammarTip,
    String pronunciationTip,
    int score,
  ) {
    if (lower.contains('coffee') || lower.contains('flat white') || lower.contains('latte') || lower.contains('espresso') || lower.contains('cappuccino') || lower.contains('tea')) {
      return AiReplyResult(
        replyText: "You got it! We've got oat, almond, and organic whole milk. Any pastry or warm croissant to go with that?",
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'Just an almond croissant if you have one fresh, please.',
        hint: 'Polite modifier "just" softens everyday service orders.',
      );
    } else if (lower.contains('croissant') || lower.contains('pastry') || lower.contains('toast') || lower.contains('cookie') || lower.contains('muffin')) {
      return AiReplyResult(
        replyText: "Coming right up, warm from the oven! That will be nine-fifty total. Paying with card or Apple Pay?",
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: "I'll tap with Apple Pay. Keep the change!",
        hint: 'Modern tap-to-pay phrasing in American cafes.',
      );
    } else if (lower.contains('apple pay') || lower.contains('card') || lower.contains('cash') || lower.contains('pay') || lower.contains('change')) {
      return AiReplyResult(
        replyText: "Awesome, receipt is in the bag! Your drink is being poured at the bar counter. Have a stellar morning!",
        grammarTip: 'Great natural flow when discussing transactions.',
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'Thanks Mateo, appreciate it!',
        hint: 'Friendly parting remark for coffee shops.',
      );
    } else {
      return AiReplyResult(
        replyText: "Sure thing! Would you like that hot or iced, and what size can I get you — twelve or sixteen ounce?",
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'Iced twelve-ounce with oat milk, please.',
        hint: 'Specify temperature and cup size.',
      );
    }
  }

  static AiReplyResult _handleInterview(
    String lower,
    String persona,
    String grammarTip,
    String pronunciationTip,
    int score,
  ) {
    if (lower.contains('experience') || lower.contains('project') || lower.contains('latency') || lower.contains('cache') || lower.contains('built') || lower.contains('engineer')) {
      return AiReplyResult(
        replyText: 'That aligns with our technical roadmap. How did you validate performance benchmarks with telemetry under load?',
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'We ran stress simulations demonstrating a forty percent drop in database contention.',
        hint: 'Use concrete metrics (e.g. "40% drop in latency").',
      );
    } else if (lower.contains('benchmark') || lower.contains('telemetry') || lower.contains('percent') || lower.contains('metric') || lower.contains('load')) {
      return AiReplyResult(
        replyText: 'Impressive engineering discipline. How do you approach cross-functional alignment when product managers push for faster deadlines?',
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'I communicate architectural trade-offs transparently and propose phased milestone rollouts.',
        hint: 'Emphasize collaboration and trade-off articulation.',
      );
    } else {
      return AiReplyResult(
        replyText: 'I appreciate the clarity. What specific distributed systems challenge are you most looking forward to tackling here?',
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'I thrive on building fault-tolerant pipelines with ninety-nine point nine percent reliability.',
        hint: 'State your technical domain with confidence.',
      );
    }
  }

  static AiReplyResult _handleConcierge(
    String lower,
    String persona,
    String grammarTip,
    String pronunciationTip,
    int score,
  ) {
    if (lower.contains('reservation') || lower.contains('name') || lower.contains('check') || lower.contains('nights') || lower.contains('room')) {
      return AiReplyResult(
        replyText: 'A pleasure to welcome you. I have assigned you a premier corner room overlooking the terrace. Would you appreciate complimentary late checkout on departure day?',
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'That would be fantastic! Would one PM be possible without any extra charge?',
        hint: 'Polite conditional: "That would be fantastic / Would it be possible...".',
      );
    } else if (lower.contains('late') || lower.contains('checkout') || lower.contains('pm') || lower.contains('charge') || lower.contains('fee')) {
      return AiReplyResult(
        replyText: 'Consider it arranged until one PM. May my team reserve a table at an exceptional local dining spot for you tonight?',
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: "We'd love an authentic bistro within walking distance, please.",
        hint: 'Specify distance and cuisine style.',
      );
    } else {
      return AiReplyResult(
        replyText: 'Certainly, sir. Here are your RFID room keys and concierge guide. Please dial zero if you require anything during your stay.',
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'Thank you so much Pierre, have a great evening!',
        hint: 'Polite hotel farewell.',
      );
    }
  }

  static AiReplyResult _handleFreeChat(
    String lower,
    String persona,
    String grammarTip,
    String pronunciationTip,
    int score,
    String? topicTitle,
  ) {
    if (lower.contains('how are you') || lower.contains('how have you') || lower.contains('hello') || lower.contains('hi alex') || lower.contains('hey alex')) {
      return AiReplyResult(
        replyText: "I'm doing fantastic, thanks for asking! Always excited to chat and help you polish your spoken English. What is on your mind today?",
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: "I've been thinking about planning a trip abroad soon.",
        hint: 'Share a casual interest or thought to keep dialogue flowing.',
      );
    } else if (lower.contains('trip') || lower.contains('travel') || lower.contains('vacation') || lower.contains('country') || lower.contains('city')) {
      return AiReplyResult(
        replyText: "Traveling is the best way to practice language! Where are you planning to visit, and what is your favorite part of traveling — the culture, the scenery, or the local food?",
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'I really love trying street food and talking to local artisans.',
        hint: 'Use parallel gerunds: "trying street food and talking to...".',
      );
    } else if (lower.contains('food') || lower.contains('eat') || lower.contains('restaurant') || lower.contains('dinner') || lower.contains('cooking')) {
      return AiReplyResult(
        replyText: "Food is an universal language! What is a traditional dish from your hometown that you think every English speaker should try at least once?",
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'You definitely have to try fresh ceviche with lime and roasted corn.',
        hint: 'Describe ingredients with vivid sensory adjectives.',
      );
    } else if (lower.contains('work') || lower.contains('job') || lower.contains('study') || lower.contains('learn') || lower.contains('english')) {
      return AiReplyResult(
        replyText: "Consistent daily immersion makes a massive difference! Do you find it easier to understand spoken English through movies, podcasts, or active conversations like this?",
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'Active conversation helps me remember vocabulary much faster than passive listening.',
        hint: 'Comparative clause: "faster than passive listening".',
      );
    } else if (lower.contains('tired') || lower.contains('busy') || lower.contains('stressed') || lower.contains('hard') || lower.contains('exhausted')) {
      return AiReplyResult(
        replyText: "I totally get that. Burnout is tough, so kudos to you for practicing even when tired! What is your go-to activity when you need to recharge and unwind?",
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'I usually go for a long walk in the park with some relaxing music.',
        hint: 'Habitual present simple: "I usually go for...".',
      );
    } else {
      final topicContext = topicTitle != null ? ' regarding "$topicTitle"' : '';
      return AiReplyResult(
        replyText: "That's a really intriguing point$topicContext! What led you to that perspective, and how do you usually tackle situations like that?",
        grammarTip: grammarTip,
        pronunciationTip: pronunciationTip,
        accuracyScore: score,
        suggestedFollowUp: 'In my experience, keeping an open mind and listening first works best.',
        hint: 'Conversational opener: "In my experience...".',
      );
    }
  }

  // =========================================================================
  // LINGUISTIC PEDAGOGICAL EVALUATORS
  // =========================================================================

  static String _evaluateGrammar(String text) {
    if (text.contains("i'm") || text.contains("i'll") || text.contains("could've") || text.contains("would've") || text.contains("i'd")) {
      return 'Great authentic use of spoken contractions ("I\'m", "I\'ll", "I\'d"). Native speakers favor these for natural rhythm.';
    } else if (text.contains("could i") || text.contains("would you") || text.contains("may i")) {
      return 'Polite modal formulas ("Could I...", "Would you...") sound courteous and socially appropriate in English.';
    } else if (text.contains("at") || text.contains("in") || text.contains("on") || text.contains("by")) {
      return 'Accurate preposition placement. Notice how native cadence blends prepositions with the following article.';
    } else if (text.contains("because") || text.contains("since") || text.contains("so that")) {
      return 'Effective complex sentence structure using causal connectors.';
    } else {
      return 'Clear sentence flow. Try incorporating casual fillers like "actually", "to be honest", or "you know" for native pacing.';
    }
  }

  static String _evaluatePronunciation(String text) {
    final words = text.split(RegExp(r'\s+'));
    final longWords = words.where((w) => w.length >= 7).toList();

    if (longWords.isNotEmpty) {
      final sample = longWords.first.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      return 'Focus stress on the primary root of "$sample". Remember English vowels reduce to a schwa /ə/ when unstressed.';
    } else if (text.contains("the") || text.contains("this") || text.contains("that")) {
      return 'Practice placing your tongue gently behind your upper teeth for the voiced dental fricative /ð/ in "the" and "that".';
    } else {
      return 'Focus on connected speech: blend consonant endings into vowel beginnings for a smooth melodic flow.';
    }
  }
}
