enum DrillType {
  sentenceScramble,
  pictureChoice,
  shadowing,
  clozeFill,
  syllableStress,
  listeningComprehension,
  scienceFactContext,
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
  final String trickTip;

  // For Scramble
  final List<String> targetSentenceWords;
  final List<String> bankWords;

  // For Picture Choice
  final List<PictureChoiceOption> pictureOptions;

  // For Shadowing
  final String targetSpeechText;
  final List<String> phoneticTokens;
  final String expectedAccentTip;

  // For Cloze Fill (Missing Word)
  final String clozePrefix;
  final String clozeSuffix;
  final List<String> clozeOptions;
  final String correctClozeAnswer;

  // For Syllable Stress
  final List<String> syllables;
  final int correctSyllableIndex;
  final String ipaPhonetic;

  // For Listening Comprehension
  final String audioScript;
  final String comprehensionQuestion;
  final List<String> listeningOptions;
  final String correctListeningAnswer;

  // For Science & Real-World Facts
  final String factBadge;
  final String factSnippet;
  final String factQuestion;
  final List<String> scienceOptions;
  final String correctScienceAnswer;

  const ExerciseModel({
    required this.id,
    required this.type,
    required this.prompt,
    this.subtitle = '',
    this.trickTip = '',
    this.targetSentenceWords = const [],
    this.bankWords = const [],
    this.pictureOptions = const [],
    this.targetSpeechText = '',
    this.phoneticTokens = const [],
    this.expectedAccentTip = '',
    this.clozePrefix = '',
    this.clozeSuffix = '',
    this.clozeOptions = const [],
    this.correctClozeAnswer = '',
    this.syllables = const [],
    this.correctSyllableIndex = 0,
    this.ipaPhonetic = '',
    this.audioScript = '',
    this.comprehensionQuestion = '',
    this.listeningOptions = const [],
    this.correctListeningAnswer = '',
    this.factBadge = '',
    this.factSnippet = '',
    this.factQuestion = '',
    this.scienceOptions = const [],
    this.correctScienceAnswer = '',
  });
}
