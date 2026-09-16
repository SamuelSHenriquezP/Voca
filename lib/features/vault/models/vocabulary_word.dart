enum MasteryTier {
  review, // Needs immediate review
  learning, // In progress
  mastered, // Fully acquired
}

class VocabularyWord {
  final String id;
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String definition;
  final String exampleSentence;
  final String category;
  final MasteryTier tier;
  final int daysUntilReview;
  final int accuracy; // e.g. 94%

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definition,
    required this.exampleSentence,
    required this.category,
    required this.tier,
    required this.daysUntilReview,
    required this.accuracy,
  });

  VocabularyWord copyWith({
    MasteryTier? tier,
    int? daysUntilReview,
    int? accuracy,
  }) {
    return VocabularyWord(
      id: id,
      word: word,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
      definition: definition,
      exampleSentence: exampleSentence,
      category: category,
      tier: tier ?? this.tier,
      daysUntilReview: daysUntilReview ?? this.daysUntilReview,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'phonetic': phonetic,
      'partOfSpeech': partOfSpeech,
      'definition': definition,
      'exampleSentence': exampleSentence,
      'category': category,
      'tier': tier.name,
      'daysUntilReview': daysUntilReview,
      'accuracy': accuracy,
    };
  }

  factory VocabularyWord.fromMap(Map<String, dynamic> map) {
    return VocabularyWord(
      id: map['id']?.toString() ?? '',
      word: map['word']?.toString() ?? '',
      phonetic: map['phonetic']?.toString() ?? '',
      partOfSpeech: map['partOfSpeech']?.toString() ?? '',
      definition: map['definition']?.toString() ?? '',
      exampleSentence: map['exampleSentence']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      tier: MasteryTier.values.firstWhere(
        (t) => t.name == map['tier'],
        orElse: () => MasteryTier.learning,
      ),
      daysUntilReview: (map['daysUntilReview'] as num?)?.toInt() ?? 1,
      accuracy: (map['accuracy'] as num?)?.toInt() ?? 90,
    );
  }
}

