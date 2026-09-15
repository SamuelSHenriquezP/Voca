class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final String time;
  final String? coachGrammarTip;
  final String? coachPronunciationTip;
  final int? accuracyScore;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.coachGrammarTip,
    this.coachPronunciationTip,
    this.accuracyScore,
  });
}

