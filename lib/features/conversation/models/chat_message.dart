class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final String time;
  final String? personaName;
  final String? coachGrammarTip;
  final String? coachPronunciationTip;
  final int? accuracyScore;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.personaName,
    this.coachGrammarTip,
    this.coachPronunciationTip,
    this.accuracyScore,
  });
}

