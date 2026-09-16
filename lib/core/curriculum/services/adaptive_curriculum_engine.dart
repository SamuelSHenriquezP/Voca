import 'dart:math' as math;
import '../data/conversation_topics_catalog.dart';
import '../../../../features/lesson/models/exercise.dart';

enum LearnerWeakness {
  vowels,
  consonants,
  prepositions,
  wordOrder,
  syllableStress,
}

class AdaptiveCurriculumEngine {
  AdaptiveCurriculumEngine._();

  static final Map<LearnerWeakness, int> _weaknessFrequency = {
    LearnerWeakness.vowels: 0,
    LearnerWeakness.consonants: 0,
    LearnerWeakness.prepositions: 0,
    LearnerWeakness.wordOrder: 0,
    LearnerWeakness.syllableStress: 0,
  };

  static void recordWeakness(LearnerWeakness weakness) {
    _weaknessFrequency[weakness] = (_weaknessFrequency[weakness] ?? 0) + 1;
  }

  static LearnerWeakness get dominantWeakness {
    var maxCount = -1;
    var dominant = LearnerWeakness.prepositions;
    _weaknessFrequency.forEach((weakness, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = weakness;
      }
    });
    return dominant;
  }

  /// Generates an adapted, pedagogically responsive 4-5 exercise lesson
  /// tailored directly to the topic and the user's detected weak areas.
  static List<ExerciseModel> generateAdaptiveLessonForTopic(String topicId) {
    final topic = ConversationTopicsCatalog.getTopicById(topicId) ??
        ConversationTopicsCatalog.allTopics.first;

    final weakness = dominantWeakness;
    final List<ExerciseModel> exercises = [];

    // 1. Scramble Drill (Adapted to target grammar)
    exercises.add(
      ExerciseModel(
        id: '${topic.id}_scramble',
        type: DrillType.sentenceScramble,
        prompt: 'Arrange the sentence to express:',
        subtitle: '"${topic.pedagogicalObjective}"',
        trickTip: 'Native Trick: Spoken English favors starting clauses with discourse markers or polite modal formulas ("Could you please...").',
        targetSentenceWords: _buildSentenceForGrammar(topic.targetGrammar),
        bankWords: _buildBankForGrammar(topic.targetGrammar),
      ),
    );

    // 2. Cloze Fill Drill (Pivoted to prepositions/collocations or target weakness)
    final clozeData = _buildClozeForTopic(topic, weakness);
    exercises.add(
      ExerciseModel(
        id: '${topic.id}_cloze',
        type: DrillType.clozeFill,
        prompt: 'Fill in the missing word:',
        subtitle: 'Collocation in ${topic.category} context',
        trickTip: clozeData['trick'] as String,
        clozePrefix: clozeData['prefix'] as String,
        clozeSuffix: clozeData['suffix'] as String,
        clozeOptions: List<String>.from(clozeData['options'] as List),
        correctClozeAnswer: clozeData['answer'] as String,
      ),
    );

    // 3. Syllable Stress Rhythm Drill (Pivoted to acoustic cadence)
    final stressData = _buildStressForTopic(topic);
    exercises.add(
      ExerciseModel(
        id: '${topic.id}_stress',
        type: DrillType.syllableStress,
        prompt: 'Tap the stressed syllable:',
        subtitle: 'Notice the pitch rise and vowel reduction',
        trickTip: stressData['trick'] as String,
        ipaPhonetic: stressData['ipa'] as String,
        syllables: List<String>.from(stressData['syllables'] as List),
        correctSyllableIndex: stressData['index'] as int,
      ),
    );

    // 4. Picture & Meaning Choice Drill
    exercises.add(
      ExerciseModel(
        id: '${topic.id}_choice',
        type: DrillType.pictureChoice,
        prompt: 'Which phrase best matches: "${topic.title}"?',
        subtitle: 'Authentic pragmatic reply with ${topic.npcName}',
        pictureOptions: const [
          PictureChoiceOption(
            id: 'opt_1',
            label: 'The Authentic Collocation',
            audioPhonetic: '/kəˈnek.tɪd spiːtʃ/',
            isCorrect: true,
          ),
          PictureChoiceOption(
            id: 'opt_2',
            label: 'Stiff Literal Translation',
            audioPhonetic: '/ˈlɪt.ɚ.əl/',
            isCorrect: false,
          ),
          PictureChoiceOption(
            id: 'opt_3',
            label: 'Formal Textbook Counterpart',
            audioPhonetic: '/ˈtɛkst.bʊk/',
            isCorrect: false,
          ),
          PictureChoiceOption(
            id: 'opt_4',
            label: 'Casual Filler Pause',
            audioPhonetic: '/ˈfɪl.ɚ/',
            isCorrect: false,
          ),
        ],
      ),
    );

    // 5. Shadowing Drill (Phoneme acoustic focus)
    exercises.add(
      ExerciseModel(
        id: '${topic.id}_shadow',
        type: DrillType.shadowing,
        prompt: 'Speak this sentence with native cadence:',
        targetSpeechText: '"${_buildShadowSentence(topic)}"',
        phoneticTokens: ['[speak naturally]', '[link the sounds]', '[clear rhythm]'],
        expectedAccentTip: 'Target Phoneme: ${topic.targetPhonemeFocus}.',
      ),
    );

    return exercises;
  }

  static List<String> _buildSentenceForGrammar(String grammar) {
    if (grammar.contains('Modal') || grammar.contains('Would') || grammar.contains('Could')) {
      return ['Could', 'you', 'please', 'clarify', 'that', 'point', 'for', 'us?'];
    }
    if (grammar.contains('Conditionals') || grammar.contains('If')) {
      return ['If', 'we', 'had', 'known', 'we', 'would', 'have', 'acted.'];
    }
    if (grammar.contains('Present Perfect')) {
      return ['Have', 'you', 'already', 'received', 'the', 'updated', 'report?'];
    }
    return ['I', 'would', 'really', 'appreciate', 'your', 'quick', 'feedback.'];
  }

  static List<String> _buildBankForGrammar(String grammar) {
    final sentence = _buildSentenceForGrammar(grammar);
    final distractors = ['never', 'always', 'tomorrow', 'already'];
    final bank = List<String>.from(sentence)..addAll(distractors);
    bank.shuffle();
    return bank;
  }

  static Map<String, dynamic> _buildClozeForTopic(
      ConversationTopicMeta topic, LearnerWeakness weakness) {
    if (weakness == LearnerWeakness.prepositions || topic.category == 'Workplace') {
      return {
        'prefix': "We need to follow",
        'suffix': "on the client's proposal by Friday.",
        'options': ['up', 'down', 'with', 'on'],
        'answer': 'up',
        'trick': 'Native Trick: "Follow up ON" is the universal business idiom for checking status.',
      };
    }
    return {
      'prefix': "I completely agree",
      'suffix': "your perspective on this matter.",
      'options': ['with', 'to', 'for', 'about'],
      'answer': 'with',
      'trick': 'Native Trick: In English, you "agree WITH" a person or opinion, never "agree to" a person.',
    };
  }

  static Map<String, dynamic> _buildStressForTopic(ConversationTopicMeta topic) {
    final words = [
      {
        'word': 'COMFORTABLE',
        'syllables': ['COM', 'FOR', 'TA', 'BLE'],
        'index': 0,
        'ipa': '/ˈkʌmf.tɚ.bəl/',
        'trick': 'Native Trick: The second vowel is reduced to silence in fluent speech: 3 syllables /ˈkʌmf-tə-bəl/.',
      },
      {
        'word': 'PHOTOGRAPHY',
        'syllables': ['PHO', 'TOG', 'RA', 'PHY'],
        'index': 1,
        'ipa': '/fəˈtɑː.ɡrə.fi/',
        'trick': 'Native Trick: Stress shifts from PHO-to-graph to pho-TOG-ra-phy with schwa reduction.',
      },
      {
        'word': 'DEFINITELY',
        'syllables': ['DEF', 'I', 'NITE', 'LY'],
        'index': 0,
        'ipa': '/ˈdef.ə.nət.li/',
        'trick': 'Native Trick: Primary stress is on DEF. The middle vowel is a relaxed schwa /ə/.',
      },
    ];

    final selected = words[math.Random().nextInt(words.length)];
    return selected;
  }

  static String _buildShadowSentence(ConversationTopicMeta topic) {
    return 'That sounds like a great plan, let us catch up tomorrow morning.';
  }
}
