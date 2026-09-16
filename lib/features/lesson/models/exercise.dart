enum DrillType {
  sentenceScramble,
  pictureChoice,
  shadowing,
}

class PictureChoiceOption {
  final String id;
  final String label;
  final String emoji;
  final String audioPhonetic;
  final bool isCorrect;

  const PictureChoiceOption({
    required this.id,
    required this.label,
    this.emoji = '',
    required this.audioPhonetic,
    required this.isCorrect,
  });
}

class ExerciseModel {
  final String id;
  final DrillType type;
  final String prompt;
  final String subtitle;

  // For Scramble
  final List<String> targetSentenceWords;
  final List<String> bankWords;

  // For Picture Choice
  final List<PictureChoiceOption> pictureOptions;

  // For Shadowing
  final String targetSpeechText;
  final List<String> phoneticTokens;
  final String expectedAccentTip;

  const ExerciseModel({
    required this.id,
    required this.type,
    required this.prompt,
    this.subtitle = '',
    this.targetSentenceWords = const [],
    this.bankWords = const [],
    this.pictureOptions = const [],
    this.targetSpeechText = '',
    this.phoneticTokens = const [],
    this.expectedAccentTip = '',
  });
}

