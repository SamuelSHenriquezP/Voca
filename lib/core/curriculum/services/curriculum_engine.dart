import 'dart:math' as math;
import '../data/conversation_topics_catalog.dart';
import '../models/curriculum_unit.dart';

class CurriculumEngine {
  CurriculumEngine._();

  /// Calculates the horizontal sine-wave coordinate for any level index
  static double calculateSineOffset(int nodeIndex) {
    return math.sin(nodeIndex * 0.85) * 0.65;
  }

  /// Builds a fully scaffolded, pedagogically validated CurriculumUnit based on SLA & TBLT
  static CurriculumUnit generateUnitForTopic(String topicId) {
    final meta = ConversationTopicsCatalog.getTopicById(topicId) ??
        ConversationTopicsCatalog.allTopics.first;

    // Build pedagogical vocabulary based on topic category
    final vocab = _generateVocabularyForTopic(meta);

    // Build the 5 Cognitive Load Nodes
    final node1 = _buildRecognitionNode(meta, vocab);
    final node2 = _buildSyntaxNode(meta, vocab);
    final node3 = _buildShadowingNode(meta, vocab);
    final node4 = _buildInteractiveStoryNode(meta, vocab);
    final node5 = _buildBossFightNode(meta, vocab);

    return CurriculumUnit(
      metadata: UnitMetadata(
        unitId: meta.id,
        cefrLevel: meta.cefrLevel,
        title: meta.title,
        pedagogicalObjective: meta.pedagogicalObjective,
        targetGrammar: meta.targetGrammar,
        targetPhonemeFocus: meta.targetPhonemeFocus,
        newVocabulary: vocab,
      ),
      nodes: [node1, node2, node3, node4, node5],
    );
  }

  // ==========================================
  // NODE 1: RECOGNITION & PRIMING (Low Load)
  // ==========================================
  static CurriculumNode _buildRecognitionNode(
      ConversationTopicMeta meta, List<VocabularyItem> vocab) {
    return CurriculumNode(
      nodeId: '${meta.id}_n1',
      nodeIndex: 1,
      type: CurriculumNodeType.drillRecognition,
      title: 'Vocabulary Priming & Recognition',
      exercises: [
        {
          'type': 'multiple_choice',
          'prompt_en': 'Which item would you say to naturally express: "${vocab[0].definitionEs}"?',
          'prompt_audio_hint': vocab[0].word,
          'options': [
            vocab[0].word,
            'unrelated item',
            'completely different',
            'formal counterpart'
          ],
          'correct_index': 0,
          'explanation_es': 'En inglés hablado natural, "${vocab[0].word}" se utiliza habitualmente en contextos como: "${vocab[0].contextSentence}".',
        },
        if (vocab.length > 1)
          {
            'type': 'multiple_choice',
            'prompt_en': 'Identify the correct pronunciation and meaning of "${vocab[1].word}":',
            'prompt_audio_hint': vocab[1].word,
            'options': [
              vocab[1].definitionEs,
              'Significado opuesto o incorrecto',
              'Término puramente gramatical',
              'Ninguna de las anteriores'
            ],
            'correct_index': 0,
            'explanation_es': '${vocab[1].word} (${vocab[1].ipa}): ${vocab[1].definitionEs}.',
          },
      ],
    );
  }

  // ==========================================
  // NODE 2: SYNTAX & SENTENCE CONSTRUCTION (Medium Load)
  // ==========================================
  static CurriculumNode _buildSyntaxNode(
      ConversationTopicMeta meta, List<VocabularyItem> vocab) {
    final targetSentence = vocab[0].contextSentence;
    final words = targetSentence.replaceAll('.', '').replaceAll('?', '').split(' ')..shuffle();

    return CurriculumNode(
      nodeId: '${meta.id}_n2',
      nodeIndex: 2,
      type: CurriculumNodeType.drillSyntax,
      title: 'Syntax & Sentence Construction',
      exercises: [
        {
          'type': 'sentence_scramble',
          'target_sentence': targetSentence,
          'scrambled_words': words,
          'grammar_tip_es': 'Estructura gramatical objetivo: ${meta.targetGrammar}. Presta atención al orden de los auxiliares y contracciones.',
        },
      ],
    );
  }

  // ==========================================
  // NODE 3: ACOUSTIC EAR & SHADOWING (Phonetic Focus)
  // ==========================================
  static CurriculumNode _buildShadowingNode(
      ConversationTopicMeta meta, List<VocabularyItem> vocab) {
    return CurriculumNode(
      nodeId: '${meta.id}_n3',
      nodeIndex: 3,
      type: CurriculumNodeType.shadowingPhonetics,
      title: 'Acoustic Ear & Shadowing',
      exercises: [
        {
          'type': 'shadowing',
          'sentence': vocab[0].contextSentence,
          'ipa': vocab[0].ipa,
          'stress_guide': _generateStressGuide(vocab[0].contextSentence),
          'common_hispanic_error_tip':
              'Enfoque fonético: ${meta.targetPhonemeFocus}. Los hispanohablantes tienden a vocalizar una "e" de apoyo o acentuar todas las sílabas por igual; mantén el ritmo de acentuación por tiempo (stress-timed rhythm).',
        },
      ],
    );
  }

  // ==========================================
  // NODE 4: INTERACTIVE MICRO-DIALOGUE (Contextual Comprehension)
  // ==========================================
  static CurriculumNode _buildInteractiveStoryNode(
      ConversationTopicMeta meta, List<VocabularyItem> vocab) {
    return CurriculumNode(
      nodeId: '${meta.id}_n4',
      nodeIndex: 4,
      type: CurriculumNodeType.interactiveStory,
      title: 'Interactive Micro-Dialogue',
      storyTurns: [
        StoryTurn(
          speaker: meta.npcName,
          text: 'Hello there. Let\'s get right to it regarding our situation today.',
          questionTrigger: QuestionTrigger(
            question: 'What is the tone and communicative intent of ${meta.npcName}?',
            options: [
              'Professional and ready to address the matter directly',
              'Angry and refusing to cooperate',
              'Confused and asking for translation'
            ],
            correctIndex: 0,
          ),
        ),
        StoryTurn(
          speaker: 'You',
          text: vocab[0].contextSentence,
        ),
        StoryTurn(
          speaker: meta.npcName,
          text: 'Understood. That makes complete sense. We can proceed on those exact terms.',
          questionTrigger: const QuestionTrigger(
            question: 'Did the speaker succeed in conveying their communicative goal?',
            options: [
              'Yes, the terms were clearly acknowledged and accepted',
              'No, the request was rejected completely',
              'There was a misunderstanding about the location'
            ],
            correctIndex: 0,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // NODE 5: THE BOSS FIGHT (High Retrieval & Live Voice Spoken Task)
  // ==========================================
  static CurriculumNode _buildBossFightNode(
      ConversationTopicMeta meta, List<VocabularyItem> vocab) {
    final targetWords = vocab.map((v) => v.word).toList();

    return CurriculumNode(
      nodeId: '${meta.id}_n5',
      nodeIndex: 5,
      type: CurriculumNodeType.bossFightCall,
      title: 'Boss Fight: ${meta.title}',
      scenario: BossFightScenario(
        npcName: meta.npcName,
        npcRole: meta.npcRole,
        npcPersonality: meta.npcPersonality,
        npcInitialAudioGreeting:
            'Hello. I\'m ${meta.npcName}, ${meta.npcRole}. How can I assist you with ${meta.title.toLowerCase()} today?',
        systemPromptForAi: '''
You are "${meta.npcName}", acting as the ${meta.npcRole} in this realistic spoken English simulation.
SCENARIO: ${meta.title} (${meta.cefrLevel} Level).
PERSONALITY: ${meta.npcPersonality}.

OBJECTIVE FOR THE USER:
${meta.pedagogicalObjective}

BEHAVIORAL INSTRUCTIONS:
1. Speak exclusively in natural spoken English matching ${meta.cefrLevel} comprehension.
2. Present mild realistic friction or follow-up questions to test the user's spoken retrieval.
3. If the user uses clear language and addresses their goal, validate them and conclude the transaction successfully.
4. Keep your responses conversational, concise (1-3 sentences), and prompt the user back.

OUTPUT STRICTLY IN JSON:
{
  "spoken_response": "The spoken words for the text-to-speech engine.",
  "silent_feedback": "A concise grammatical or phonetic tip if they made an error, or null if accurate."
}
''',
        missionGoals: [
          'Goal 1: State your situation clearly using target conversational vocabulary',
          'Goal 2: Answer follow-up questions from ${meta.npcName} without freezing',
          'Goal 3: Successfully achieve the communicative objective: ${meta.pedagogicalObjective}',
        ],
        vocabularyRequiredToWin: targetWords,
        successCriteriaSummary:
            'User must maintain spoken fluency, address all goals, and use at least two key lexical structures.',
      ),
    );
  }

  // Helper to generate realistic CEFR-aligned vocabulary per topic
  static List<VocabularyItem> _generateVocabularyForTopic(ConversationTopicMeta meta) {
    // If it's coffee shop (a1_02)
    if (meta.id == 'a1_02') {
      return const [
        VocabularyItem(
          word: 'flat white',
          ipa: '/ˌflæt ˈwaɪt/',
          definitionEs: 'Café espresso con una capa fina de leche vaporizada y microespuma sedosa.',
          contextSentence: 'Could I get a medium flat white with oat milk, please?',
        ),
        VocabularyItem(
          word: 'to go',
          ipa: '/tə ˈɡoʊ/',
          definitionEs: 'Para llevar (término estándar en inglés americano en lugar de takeaway).',
          contextSentence: 'Is that for here or to go?',
        ),
        VocabularyItem(
          word: 'extra hot',
          ipa: '/ˌek.strə ˈhɑːt/',
          definitionEs: 'Instrucción de temperatura para calentar la leche por encima de los 65°C.',
          contextSentence: 'Could you make that extra hot? It\'s freezing outside.',
        ),
      ];
    }

    // If it's airport immigration (b1_01)
    if (meta.id == 'b1_01') {
      return const [
        VocabularyItem(
          word: 'itinerary',
          ipa: '/aɪˈtɪn.ə.rer.i/',
          definitionEs: 'Plan detallado de viaje con fechas, vuelos y alojamientos confirmados.',
          contextSentence: 'I have a printed copy of my return flight itinerary right here.',
        ),
        VocabularyItem(
          word: 'length of stay',
          ipa: '/leŋθ əv steɪ/',
          definitionEs: 'Duración exacta prevista de estancia en el país de destino.',
          contextSentence: 'My intended length of stay is twelve consecutive days.',
        ),
        VocabularyItem(
          word: 'customs declaration',
          ipa: '/ˈkʌs.təmz ˌdek.ləˈreɪ.ʃən/',
          definitionEs: 'Formulario oficial donde se declaran bienes comerciales o divisas.',
          contextSentence: 'I have nothing to declare on my customs declaration form.',
        ),
      ];
    }

    // Default domain-driven generation
    return [
      VocabularyItem(
        word: meta.targetGrammar.split(' ').take(2).join(' ').toLowerCase(),
        ipa: '/ˈtɑːr.ɡɪt/',
        definitionEs: 'Expresión clave para desenvolverse con soltura en este escenario.',
        contextSentence: 'I would like to clarify the details regarding our plan.',
      ),
      const VocabularyItem(
        word: 'proceed',
        ipa: '/prəˈsiːd/',
        definitionEs: 'Avanzar o continuar formalmente con una acción o trámite.',
        contextSentence: 'We can now proceed to the next stage of our discussion.',
      ),
    ];
  }

  static String _generateStressGuide(String sentence) {
    final words = sentence.split(' ');
    return words.map((w) {
      if (w.length > 5) {
        return w.toUpperCase();
      }
      return w.toLowerCase();
    }).join(' ');
  }
}
