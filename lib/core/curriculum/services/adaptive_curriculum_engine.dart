import '../data/conversation_topics_catalog.dart';
import '../../../../features/lesson/models/exercise.dart';
import '../../../../features/path/models/level_node.dart';
import '../../storage/local_storage_service.dart';

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

  /// Generates a pedagogically rigorous 5-exercise lesson
  /// tailored directly to the specified topic, target grammar, vocabulary, and focus type.
  static List<ExerciseModel> generateAdaptiveLessonForTopic(
    String topicId, {
    LevelFocusType focusType = LevelFocusType.syntaxBattle,
  }) {
    final topic = ConversationTopicsCatalog.getTopicById(topicId) ??
        ConversationTopicsCatalog.allTopics.first;

    final weakness = dominantWeakness;
    final List<ExerciseModel> exercises = [];
    final perfectStreak = LocalStorageService().getPerfectLessonStreak();
    final isAdaptiveHard = perfectStreak >= 1;

    switch (focusType) {
      case LevelFocusType.storyReading:
        // 1. Lore Story Passage with blanks completion
        exercises.add(_buildStoryPassageForTopic(topic));
        // 2. Target Cloze grammar slot
        final cl1 = _buildClozeForTopic(topic, weakness);
        exercises.add(ExerciseModel(
          id: '${topic.id}_story_cloze',
          type: DrillType.clozeFill,
          prompt: 'Completa la frase clave de la historia:',
          subtitle: 'Gramática de la aventura • ${topic.title}',
          trickTip: cl1['trick'] as String,
          clozePrefix: cl1['prefix'] as String,
          clozeSuffix: cl1['suffix'] as String,
          clozeOptions: List<String>.from(cl1['options'] as List),
          correctClozeAnswer: cl1['answer'] as String,
        ));
        // 3. Audio listening detail
        exercises.add(_buildListeningForTopic(topic));
        // 4. Scramble reconstruction
        final sc1 = _buildScrambleForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_story_scramble',
          type: DrillType.sentenceScramble,
          prompt: 'Reconstruye el diálogo del capítulo:',
          subtitle: '"${sc1['meaning']}"',
          trickTip: sc1['trick'] as String,
          targetSentenceWords: List<String>.from(sc1['target'] as List),
          bankWords: List<String>.from(sc1['bank'] as List),
        ));
        // 5. Spoken shadowing of the story line
        final sh1 = _buildShadowForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_shadow',
          type: DrillType.shadowing,
          prompt: 'Pronuncia el diálogo del relato:',
          targetSpeechText: '"${sh1['sentence']}"',
          phoneticTokens: List<String>.from(sh1['tokens'] as List),
          expectedAccentTip: sh1['tip'] as String,
        ));
        break;

      case LevelFocusType.listeningLab:
        // 1. Audio Listening Comprehension
        exercises.add(_buildListeningForTopic(topic));
        // 2. Syllable Stress
        final st2 = _buildStressForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_stress',
          type: DrillType.syllableStress,
          prompt: '🎧 Laboratorio Auditivo: Toca la sílaba tónica:',
          subtitle: 'Acento y prosodia: ${topic.targetPhonemeFocus}',
          trickTip: st2['trick'] as String,
          ipaPhonetic: st2['ipa'] as String,
          syllables: List<String>.from(st2['syllables'] as List),
          correctSyllableIndex: st2['index'] as int,
        ));
        // 3. Second Audio Listening scenario
        exercises.add(_buildListeningForTopic(topic));
        // 4. Cloze Fill
        final cl2 = _buildClozeForTopic(topic, weakness);
        exercises.add(ExerciseModel(
          id: '${topic.id}_cloze',
          type: DrillType.clozeFill,
          prompt: '🎧 Reconocimiento auditivo: Completa el hueco:',
          subtitle: 'Tema: ${topic.title} (${topic.targetGrammar})',
          trickTip: cl2['trick'] as String,
          clozePrefix: cl2['prefix'] as String,
          clozeSuffix: cl2['suffix'] as String,
          clozeOptions: List<String>.from(cl2['options'] as List),
          correctClozeAnswer: cl2['answer'] as String,
        ));
        // 5. Shadowing with accent tip
        final sh2 = _buildShadowForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_shadow',
          type: DrillType.shadowing,
          prompt: 'Pronuncia imitando la entonación nativa:',
          targetSpeechText: '"${sh2['sentence']}"',
          phoneticTokens: List<String>.from(sh2['tokens'] as List),
          expectedAccentTip: sh2['tip'] as String,
        ));
        break;

      case LevelFocusType.scienceExplore:
        // 1. Science & Real-world curiosity reading
        exercises.add(_buildScienceForTopic(topic));
        // 2. Science cloze / grammar slot
        final cl3 = _buildClozeForTopic(topic, weakness);
        exercises.add(ExerciseModel(
          id: '${topic.id}_cloze',
          type: DrillType.clozeFill,
          prompt: '🔬 Exploración Científica: Precisión técnica:',
          subtitle: 'Tema: ${topic.title} (${topic.targetGrammar})',
          trickTip: cl3['trick'] as String,
          clozePrefix: cl3['prefix'] as String,
          clozeSuffix: cl3['suffix'] as String,
          clozeOptions: List<String>.from(cl3['options'] as List),
          correctClozeAnswer: cl3['answer'] as String,
        ));
        // 3. Science analysis exercise
        exercises.add(_buildScienceForTopic(topic));
        // 4. Scientific syntax scramble
        final sc3 = _buildScrambleForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_scramble',
          type: DrillType.sentenceScramble,
          prompt: '🔬 Sintaxis Científica: Estructura la deducción:',
          subtitle: '"${sc3['meaning']}"',
          trickTip: sc3['trick'] as String,
          targetSentenceWords: List<String>.from(sc3['target'] as List),
          bankWords: List<String>.from(sc3['bank'] as List),
        ));
        // 5. Spoken speech shadowing
        final sh3 = _buildShadowForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_shadow',
          type: DrillType.shadowing,
          prompt: 'Pronuncia el postulado científico en voz alta:',
          targetSpeechText: '"${sh3['sentence']}"',
          phoneticTokens: List<String>.from(sh3['tokens'] as List),
          expectedAccentTip: sh3['tip'] as String,
        ));
        break;

      case LevelFocusType.dialogueBoss:
        // 1. Authentic roleplay choice with NPC
        final ch4 = _buildChoiceForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_choice',
          type: DrillType.pictureChoice,
          prompt: '👑 DESAFÍO FINAL: Respuesta conversacional a ${topic.npcName}:',
          subtitle: '${topic.npcRole} • ${topic.pedagogicalObjective}',
          pictureOptions: List<PictureChoiceOption>.from(ch4['options'] as List),
        ));
        // 2. Listening Comprehension in Dialogue
        exercises.add(_buildListeningForTopic(topic));
        // 3. Cloze grammar slot
        final cl4 = _buildClozeForTopic(topic, weakness);
        exercises.add(ExerciseModel(
          id: '${topic.id}_cloze',
          type: DrillType.clozeFill,
          prompt: '👑 Precisión con ${topic.npcName}:',
          subtitle: topic.targetGrammar,
          trickTip: cl4['trick'] as String,
          clozePrefix: cl4['prefix'] as String,
          clozeSuffix: cl4['suffix'] as String,
          clozeOptions: List<String>.from(cl4['options'] as List),
          correctClozeAnswer: cl4['answer'] as String,
        ));
        // 4. Scramble
        final sc4 = _buildScrambleForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_scramble',
          type: DrillType.sentenceScramble,
          prompt: '👑 Estructura tu respuesta final:',
          subtitle: '"${sc4['meaning']}"',
          trickTip: sc4['trick'] as String,
          targetSentenceWords: List<String>.from(sc4['target'] as List),
          bankWords: List<String>.from(sc4['bank'] as List),
        ));
        // 5. Shadowing with native rhythm
        final sh4 = _buildShadowForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_shadow',
          type: DrillType.shadowing,
          prompt: 'Demuestra fluidez nativa en el cierre del diálogo:',
          targetSpeechText: '"${sh4['sentence']}"',
          phoneticTokens: List<String>.from(sh4['tokens'] as List),
          expectedAccentTip: sh4['tip'] as String,
        ));
        break;

      case LevelFocusType.syntaxBattle:
        // 1. Scramble
        final sc5 = _buildScrambleForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_scramble',
          type: DrillType.sentenceScramble,
          prompt: isAdaptiveHard
              ? '⚔️ Desafío de Sintaxis (Racha x$perfectStreak):'
              : '⚔️ Batalla de Sintaxis: Organiza la oración:',
          subtitle: '"${sc5['meaning']}"',
          trickTip: sc5['trick'] as String,
          targetSentenceWords: List<String>.from(sc5['target'] as List),
          bankWords: List<String>.from(sc5['bank'] as List),
        ));
        // 2. Cloze
        final cl5 = _buildClozeForTopic(topic, weakness);
        exercises.add(ExerciseModel(
          id: '${topic.id}_cloze',
          type: DrillType.clozeFill,
          prompt: isAdaptiveHard ? '⚔️ Forma exacta requerida:' : '⚔️ Completa la estructura sintáctica:',
          subtitle: 'Tema: ${topic.title} (${topic.targetGrammar})',
          trickTip: cl5['trick'] as String,
          clozePrefix: cl5['prefix'] as String,
          clozeSuffix: cl5['suffix'] as String,
          clozeOptions: List<String>.from(cl5['options'] as List),
          correctClozeAnswer: cl5['answer'] as String,
        ));
        // 3. Syllable Stress
        final st5 = _buildStressForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_stress',
          type: DrillType.syllableStress,
          prompt: 'Toca la sílaba tónica (acento principal):',
          subtitle: 'Enfoque fonético: ${topic.targetPhonemeFocus}',
          trickTip: st5['trick'] as String,
          ipaPhonetic: st5['ipa'] as String,
          syllables: List<String>.from(st5['syllables'] as List),
          correctSyllableIndex: st5['index'] as int,
        ));
        // 4. Choice
        final ch5 = _buildChoiceForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_choice',
          type: DrillType.pictureChoice,
          prompt: ch5['prompt'] as String,
          subtitle: 'Respuesta conversacional con ${topic.npcName} (${topic.npcRole})',
          pictureOptions: List<PictureChoiceOption>.from(ch5['options'] as List),
        ));
        // 5. Shadowing
        final sh5 = _buildShadowForTopic(topic);
        exercises.add(ExerciseModel(
          id: '${topic.id}_shadow',
          type: DrillType.shadowing,
          prompt: 'Pronuncia en voz alta con entonación natural:',
          targetSpeechText: '"${sh5['sentence']}"',
          phoneticTokens: List<String>.from(sh5['tokens'] as List),
          expectedAccentTip: sh5['tip'] as String,
        ));
        break;
    }

    return exercises;
  }

  // =========================================================================
  // 1. SCRAMBLE BUILDER (TOPIC-SPECIFIC REAL GRAMMAR)
  // =========================================================================
  static Map<String, dynamic> _makeScramble(
    List<String> target,
    String meaning,
    String trick,
    List<String> distractors,
  ) {
    final streak = LocalStorageService().getPerfectLessonStreak();
    final isAdaptiveHard = streak >= 1;
    final extraDistractors = isAdaptiveHard
        ? ['will', 'have', 'does', 'been', 'at', 'in', 'the', 'for']
            .where((w) => !target.contains(w) && !distractors.contains(w))
            .take(2)
            .toList()
        : <String>[];
    final bank = List<String>.from(target)..addAll(distractors)..addAll(extraDistractors);
    bank.shuffle();
    return {
      'meaning': meaning,
      'target': target,
      'bank': bank,
      'trick': isAdaptiveHard
          ? '$trick (🔥 Racha x$streak: Distractores adicionales agregados)'
          : trick,
    };
  }

  static Map<String, dynamic> _buildScrambleForTopic(ConversationTopicMeta topic) {
    // Curated exact mappings for foundation topics
    switch (topic.id) {
      case 'a1_01':
        return _makeScramble(
          ['Hello,', 'my', 'name', 'is', 'Alex', 'and', 'I', 'am', 'glad', 'to', 'meet', 'you.'],
          'Hola, mi nombre es Alex y me alegro de conocerte.',
          'Truco Nativo: "Glad to meet you" o "Nice to meet you" es la frase imprescindible para romper el hielo.',
          ['nice', 'they', 'are'],
        );
      case 'a1_02':
        return _makeScramble(
          ['Could', 'I', 'please', 'get', 'a', 'hot', 'latte', 'to', 'go?'],
          '¿Podría pedir un café con leche caliente para llevar, por favor?',
          'Truco Nativo: En inglés americano de cafetería siempre se dice "to go" (para llevar), nunca "for go".',
          ['cup', 'want', 'water'],
        );
      case 'a1_03':
        return _makeScramble(
          ['I', 'will', 'pay', 'with', 'my', 'credit', 'card', 'today,', 'thanks.'],
          'Pagaré con mi tarjeta de crédito hoy, muchas gracias.',
          'Truco Nativo: "Pay with [card]" o "pay by card" son las colocaciones estándar al pagar.',
          ['money', 'cash'],
        );
      case 'a1_04':
        return _makeScramble(
          ['Go', 'straight', 'for', 'two', 'blocks', 'and', 'turn', 'left.'],
          'Siga derecho por dos cuadras y doble a la izquierda en la esquina.',
          'Truco Nativo: Para direcciones se usan imperativos directos: "Go straight", "Turn left".',
          ['right', 'run'],
        );
      case 'a1_05':
        return _makeScramble(
          ['I', 'have', 'a', 'reservation', 'under', 'the', 'name', 'of', 'Miller.'],
          'Tengo una reserva a nombre de Miller por dos noches.',
          'Truco Nativo: En hoteles se dice "under the name of..." para indicar el titular de la reserva.',
          ['room', 'hotel'],
        );
      case 'a1_06':
        return _makeScramble(
          ['Can', 'I', 'have', 'combo', 'number', 'two', 'with', 'extra', 'sauce?'],
          '¿Puedo pedir el combo número dos con salsa barbacoa extra?',
          'Truco Nativo: "Can I have combo number..." es la forma más rápida y natural en ventanillas.',
          ['fries', 'soda'],
        );
      case 'a1_07':
        return _makeScramble(
          ['Let', 'us', 'meet', 'at', 'the', 'library', 'at', 'half', 'past', 'four.'],
          'Reunámonos en la biblioteca a las cuatro y media en punto.',
          'Truco Nativo: Con horas exactas siempre usamos la preposición "at" (ej: at half past four).',
          ['in', 'on'],
        );
      case 'a1_08':
        return _makeScramble(
          ['How', 'much', 'does', 'a', 'metro', 'card', 'cost', 'today?'],
          '¿Cuánto cuesta una tarjeta de metro para viajar hoy?',
          'Truco Nativo: Para precios incontables usamos siempre "How much does... cost?".',
          ['many', 'fare'],
        );
      case 'a1_09':
        return _makeScramble(
          ['Could', 'I', 'try', 'on', 'this', 'blue', 'shirt', 'in', 'medium?'],
          '¿Podría probarme esta camisa azul en una talla mediana?',
          'Truco Nativo: El phrasal verb separable para ropa es "try on" (probarse).',
          ['wear', 'large'],
        );
      case 'a1_10':
        return _makeScramble(
          ['My', 'older', 'brother', 'lives', 'in', 'London', 'and', 'has', 'dogs.'],
          'Mi hermano mayor vive en Londres y tiene dos perros.',
          'Truco Nativo: En tercera persona singular (he/she) añadimos "-s" al verbo: "he lives", "he has".',
          ['have', 'live'],
        );
    }

    // Dynamic Grammar Parser for all other CEFR topics
    final grammar = topic.targetGrammar;
    List<String> target;
    String meaning;

    if (grammar.contains('Present Simple') || grammar.contains('to be')) {
      target = ['I', 'am', 'very', 'happy', 'to', 'participate', 'in', 'this', 'session.'];
      meaning = 'Estoy muy contento de participar en esta sesión.';
    } else if (grammar.contains('Past Simple') || grammar.contains('ed')) {
      target = ['We', 'visited', 'the', 'historic', 'city', 'center', 'yesterday', 'afternoon.'];
      meaning = 'Visitamos el centro histórico de la ciudad ayer por la tarde.';
    } else if (grammar.contains('Present Perfect') || grammar.contains('have')) {
      target = ['Have', 'you', 'ever', 'traveled', 'to', 'an', 'English', 'speaking', 'country?'];
      meaning = '¿Alguna vez has viajado a un país de habla inglesa?';
    } else if (grammar.contains('Conditionals') || grammar.contains('If')) {
      target = ['If', 'you', 'arrive', 'early,', 'we', 'can', 'start', 'our', 'project.'];
      meaning = 'Si llegas temprano, podremos comenzar nuestro proyecto.';
    } else if (grammar.contains('Modal') || grammar.contains('Could') || grammar.contains('Should')) {
      target = ['You', 'should', 'practice', 'speaking', 'consistently', 'every', 'single', 'day.'];
      meaning = 'Deberías practicar tu habla con constancia todos los días.';
    } else if (grammar.contains('Continuous') || grammar.contains('ing')) {
      target = ['We', 'are', 'currently', 'preparing', 'our', 'keynote', 'presentation.'];
      meaning = 'Actualmente estamos preparando nuestra presentación principal.';
    } else if (grammar.contains('Passive')) {
      target = ['The', 'official', 'contract', 'was', 'signed', 'by', 'both', 'partners.'];
      meaning = 'El contrato oficial fue firmado por ambos socios.';
    } else {
      target = ['It', 'is', 'essential', 'to', 'communicate', 'ideas', 'with', 'confidence.'];
      meaning = 'Es fundamental comunicar las ideas con total seguridad.';
    }

    final distractors = ['always', 'yesterday', 'already', 'never'];
    final bank = List<String>.from(target)..addAll(distractors.take(2));
    bank.shuffle();

    return {
      'meaning': meaning,
      'target': target,
      'bank': bank,
      'trick': 'Truco Nativo: Observa la estructura sujeto + verbo auxiliar + complemento para formar oraciones fluidas.',
    };
  }

  // =========================================================================
  // 2. CLOZE BUILDER (TARGET GRAMMAR & COLLOCATIONS)
  // =========================================================================
  static Map<String, dynamic> _buildClozeForTopic(
      ConversationTopicMeta topic, LearnerWeakness weakness) {
    switch (topic.id) {
      case 'a1_01':
        return {
          'prefix': 'Hi! My name',
          'suffix': 'Emma. Where are you from?',
          'options': ['is', 'are', 'am', 'be'],
          'answer': 'is',
          'trick': 'Truco Nativo: Con sujetos singulares en 3ª persona ("my name"), usamos siempre "is".',
        };
      case 'a1_02':
        return {
          'prefix': 'I would like a medium cappuccino',
          'suffix': 'go, please.',
          'options': ['to', 'for', 'in', 'at'],
          'answer': 'to',
          'trick': 'Truco Nativo: "To go" es la fórmula fija en inglés para comida o bebida para llevar.',
        };
      case 'a1_03':
        return {
          'prefix': 'Do you',
          'suffix': 'a paper bag or a receipt today?',
          'options': ['need', 'needs', 'needing', 'to need'],
          'answer': 'need',
          'trick': 'Truco Nativo: Tras el auxiliar "Do", el verbo principal se mantiene en forma base.',
        };
      case 'a1_04':
        return {
          'prefix': 'The train station is right',
          'suffix': 'the bank and the public library.',
          'options': ['between', 'among', 'through', 'over'],
          'answer': 'between',
          'trick': 'Truco Nativo: "Between" se usa específicamente cuando hay dos puntos de referencia definidos.',
        };
      case 'a1_05':
        return {
          'prefix': 'We',
          'suffix': 'a reservation confirmed for two nights.',
          'options': ['have', 'has', 'having', 'is have'],
          'answer': 'have',
          'trick': 'Truco Nativo: Con el pronombre "We" (primera persona plural), la forma del presente es "have".',
        };
      case 'a1_06':
        return {
          'prefix': 'Would you like to',
          'suffix': 'that combo with large fries and a soda?',
          'options': ['size up', 'sized', 'sizing', 'size out'],
          'answer': 'size up',
          'trick': 'Truco Nativo: "Size up" o "upsize" se usa para agrandar la porción en cadenas de comida.',
        };
    }

    final grammar = topic.targetGrammar;
    if (grammar.contains('Present Simple') || grammar.contains('to be')) {
      return {
        'prefix': 'Where',
        'suffix': 'your colleagues working this afternoon?',
        'options': ['are', 'is', 'am', 'be'],
        'answer': 'are',
        'trick': 'Truco Nativo: "Colleagues" es plural, por lo que exige "are".',
      };
    } else if (grammar.contains('Past Simple')) {
      return {
        'prefix': 'Yesterday we',
        'suffix': 'all the project milestones on schedule.',
        'options': ['completed', 'complete', 'completing', 'completes'],
        'answer': 'completed',
        'trick': 'Truco Nativo: "Yesterday" es un indicador temporal estricto de Past Simple (-ed).',
      };
    } else if (grammar.contains('Present Perfect')) {
      return {
        'prefix': 'I have already',
        'suffix': 'the updated documentation to your inbox.',
        'options': ['sent', 'send', 'sending', 'sended'],
        'answer': 'sent',
        'trick': 'Truco Nativo: "Send" es irregular; su participio pasado es "sent" (have sent).',
      };
    } else if (grammar.contains('Conditionals')) {
      return {
        'prefix': 'If we leave now, we',
        'suffix': 'catch the express train on time.',
        'options': ['will', 'would', 'did', 'had'],
        'answer': 'will',
        'trick': 'Truco Nativo: El primer condicional combina "If + presente" con "will + infinitivo".',
      };
    } else if (grammar.contains('Modal')) {
      return {
        'prefix': 'You',
        'suffix': 'verify your flight gate before boarding.',
        'options': ['should', 'ought', 'had', 'able'],
        'answer': 'should',
        'trick': 'Truco Nativo: Los modales como "should" van seguidos directamente del verbo base sin "to".',
      };
    }

    // Default preposition/collocation fallback
    return {
      'prefix': 'I am looking forward',
      'suffix': 'working with your team on this.',
      'options': ['to', 'for', 'at', 'with'],
      'answer': 'to',
      'trick': 'Truco Nativo: La expresión idiomática es "look forward TO" siempre con "to".',
    };
  }

  // =========================================================================
  // 3. SYLLABLE STRESS BUILDER (AUTHENTIC IPA & RHYTHM)
  // =========================================================================
  static Map<String, dynamic> _buildStressForTopic(ConversationTopicMeta topic) {
    final Map<String, Map<String, dynamic>> curatedStress = {
      'a1_01': {
        'word': 'GREETING',
        'syllables': ['GREET', 'ING'],
        'index': 0,
        'ipa': '/ˈɡriː.tɪŋ/',
        'trick': 'Truco Nativo: En sustantivos de dos sílabas, la acentuación casi siempre cae en la primera sílaba.',
      },
      'a1_02': {
        'word': 'ESPRESSO',
        'syllables': ['ES', 'PRES', 'SO'],
        'index': 1,
        'ipa': '/eˈspres.oʊ/',
        'trick': 'Truco Nativo: La fuerza cae en la sílaba media "PRES", con la primera "E" suave.',
      },
      'a1_03': {
        'word': 'RECEIPT',
        'syllables': ['RE', 'CEIPT'],
        'index': 1,
        'ipa': '/rɪˈsiːt/',
        'trick': 'Truco Nativo: ¡La letra "p" en "receipt" es 100% muda! Suena exactamente como /rɪ-siːt/.',
      },
      'a1_04': {
        'word': 'DIRECTION',
        'syllables': ['DI', 'REC', 'TION'],
        'index': 1,
        'ipa': '/dɪˈrek.ʃən/',
        'trick': 'Truco Nativo: Las palabras que terminan en "-tion" casi siempre llevan el acento en la sílaba inmediatamente anterior.',
      },
      'a1_05': {
        'word': 'RESERVATION',
        'syllables': ['RES', 'ER', 'VA', 'TION'],
        'index': 2,
        'ipa': '/ˌrez.ɚˈveɪ.ʃən/',
        'trick': 'Truco Nativo: El acento tónico principal recae en "VA" (/veɪ/), elevando el tono de voz.',
      },
      'a1_06': {
        'word': 'DELICIOUS',
        'syllables': ['DE', 'LI', 'CIOUS'],
        'index': 1,
        'ipa': '/dɪˈlɪʃ.əs/',
        'trick': 'Truco Nativo: El acento cae en "LI" con vocal corta /ɪ/, y "-cious" suena suave como /ʃəs/.',
      },
      'a1_07': {
        'word': 'SCHEDULE',
        'syllables': ['SCHED', 'ULE'],
        'index': 0,
        'ipa': '/ˈskedʒ.uːl/',
        'trick': 'Truco Nativo: En inglés americano "schedule" inicia con sonido /sk/ con acento en "SCHED".',
      },
      'a1_08': {
        'word': 'PLATFORM',
        'syllables': ['PLAT', 'FORM'],
        'index': 0,
        'ipa': '/ˈplæt.fɔːrm/',
        'trick': 'Truco Nativo: El sonido /p/ al inicio se pronuncia con una pequeña ráfaga de aire (aspirado).',
      },
      'a1_09': {
        'word': 'FITTING',
        'syllables': ['FIT', 'TING'],
        'index': 0,
        'ipa': '/ˈfɪt.ɪŋ/',
        'trick': 'Truco Nativo: En inglés americano, la doble "tt" se suaviza en una "flap t" rápida.',
      },
      'a1_10': {
        'word': 'FAMILY',
        'syllables': ['FAM', 'I', 'LY'],
        'index': 0,
        'ipa': '/ˈfæm.əl.i/',
        'trick': 'Truco Nativo: El acento está en la primera sílaba "FAM", y la "i" intermedia se reduce a schwa /ə/.',
      },
    };

    if (curatedStress.containsKey(topic.id)) {
      return curatedStress[topic.id]!;
    }

    // Phonetic defaults categorized by domain
    if (topic.category == 'Workplace' || topic.category == 'Business') {
      return {
        'word': 'COLLEAGUE',
        'syllables': ['COL', 'LEAGUE'],
        'index': 0,
        'ipa': '/ˈkɑː.liːɡ/',
        'trick': 'Truco Nativo: El final "-gue" suena como una simple "g" dura (/ɡ/), sin pronunciar la "ue".',
      };
    } else if (topic.category == 'Travel') {
      return {
        'word': 'ITINERARY',
        'syllables': ['I', 'TIN', 'ER', 'A', 'RY'],
        'index': 1,
        'ipa': '/aɪˈtɪn.ə.rer.i/',
        'trick': 'Truco Nativo: El acento primario cae en "TIN", manteniendo el ritmo ágil en el resto de vocales.',
      };
    }

    return {
      'word': 'COMFORTABLE',
      'syllables': ['COM', 'FOR', 'TA', 'BLE'],
      'index': 0,
      'ipa': '/ˈkʌmf.tɚ.bəl/',
      'trick': 'Truco Nativo: En habla fluida tiene 3 sílabas reales (/ˈkʌmf.tə.bəl/); la segunda "o" no se pronuncia.',
    };
  }

  // =========================================================================
  // 4. PRAGMATIC CHOICE BUILDER (REAL CONVERSATIONAL SITUATIONS)
  // =========================================================================
  static Map<String, dynamic> _buildChoiceForTopic(ConversationTopicMeta topic) {
    switch (topic.id) {
      case 'a1_01':
        return {
          'prompt': '¿Cuál es la respuesta cortés más natural a "Nice to meet you"?',
          'options': [
            const PictureChoiceOption(
              id: 'opt_good',
              label: 'Nice to meet you too! Where are you from?',
              audioPhonetic: '/naɪs tə miːt juː tuː/',
              isCorrect: true,
            ),
            const PictureChoiceOption(
              id: 'opt_literal',
              label: 'Yes, I am a living person.',
              audioPhonetic: '/jes aɪ æm/',
              isCorrect: false,
            ),
            const PictureChoiceOption(
              id: 'opt_rude',
              label: 'Please pay me fifteen dollars.',
              audioPhonetic: '/pliːz peɪ/',
              isCorrect: false,
            ),
            const PictureChoiceOption(
              id: 'opt_bye',
              label: 'Goodbye, see you yesterday.',
              audioPhonetic: '/ɡʊdˈbaɪ/',
              isCorrect: false,
            ),
          ],
        };
      case 'a1_02':
        return {
          'prompt': '¿Cómo pides un café con leche de manera cortés y rápida?',
          'options': [
            const PictureChoiceOption(
              id: 'opt_good',
              label: 'Could I please get a hot latte to go?',
              audioPhonetic: '/kʊd aɪ pliːz ɡet/',
              isCorrect: true,
            ),
            const PictureChoiceOption(
              id: 'opt_demanding',
              label: 'I want coffee right now.',
              audioPhonetic: '/aɪ wɑːnt ˈkɑː.fi/',
              isCorrect: false,
            ),
            const PictureChoiceOption(
              id: 'opt_nonsensical',
              label: 'Coffee beans are very dark.',
              audioPhonetic: '/ˈkɑː.fi biːnz/',
              isCorrect: false,
            ),
            const PictureChoiceOption(
              id: 'opt_cold',
              label: 'Give me liquid with milk.',
              audioPhonetic: '/ɡɪv miː ˈlɪk.wɪd/',
              isCorrect: false,
            ),
          ],
        };
      case 'a1_03':
        return {
          'prompt': 'Si la cajera pregunta "¿Necesitas bolsa?", ¿cómo respondes amablemente?',
          'options': [
            const PictureChoiceOption(
              id: 'opt_good',
              label: "No bag needed, thank you! I brought a tote.",
              audioPhonetic: '/noʊ bæɡ ˈniː.dɪd/',
              isCorrect: true,
            ),
            const PictureChoiceOption(
              id: 'opt_random',
              label: 'Supermarkets are bright buildings.',
              audioPhonetic: '/ˈsuː.pɚˌmɑːr.kɪts/',
              isCorrect: false,
            ),
            const PictureChoiceOption(
              id: 'opt_bye',
              label: 'Today is definitely Saturday.',
              audioPhonetic: '/təˈdeɪ ɪz/',
              isCorrect: false,
            ),
            const PictureChoiceOption(
              id: 'opt_stiff',
              label: 'Plastic is composed of polymers.',
              audioPhonetic: '/ˈplæs.tɪk/',
              isCorrect: false,
            ),
          ],
        };
    }

    // Dynamic Pragmatic Generator based on topic objective
    return {
      'prompt': '¿Cuál de estas frases cumple mejor el objetivo de "${topic.title}"?',
      'options': [
        PictureChoiceOption(
          id: 'opt_authentic',
          label: 'Could you please assist me with ${topic.title.toLowerCase()}?',
          audioPhonetic: '/kʊd juː pliːz/',
          isCorrect: true,
        ),
        const PictureChoiceOption(
          id: 'opt_rigid',
          label: 'I require immediate execution of this command.',
          audioPhonetic: '/aɪ rɪˈkwaɪr/',
          isCorrect: false,
        ),
        const PictureChoiceOption(
          id: 'opt_unrelated',
          label: 'The weather forecast predicts rain tomorrow.',
          audioPhonetic: '/ðə ˈweð.ɚ/',
          isCorrect: false,
        ),
        const PictureChoiceOption(
          id: 'opt_awkward',
          label: 'Words are difficult in multiple foreign languages.',
          audioPhonetic: '/wɝːdz ɑːr/',
          isCorrect: false,
        ),
      ],
    };
  }

  // =========================================================================
  // 5. SHADOWING BUILDER (FLUENT SPOKEN CADENCE)
  // =========================================================================
  static Map<String, dynamic> _buildShadowForTopic(ConversationTopicMeta topic) {
    switch (topic.id) {
      case 'a1_01':
        return {
          'sentence': 'Hello! It is wonderful to meet you. My name is Alex.',
          'tokens': ['[hel-LOH]', '[it iz WUN-der-ful]', '[to meet yoo]', '[my naym iz al-eks]'],
          'tip': 'Enlaza "it is" como "it-iz" con ritmo continuo sin cortar las palabras.',
        };
      case 'a1_02':
        return {
          'sentence': 'Could I get a flat white with oat milk to go, please?',
          'tokens': ['[kood-I get]', '[a flat wyt]', '[with oat milk]', '[to go pleez]'],
          'tip': 'Pronuncia "Could I" como un solo bloque enlazado: /kʊ-daɪ/.',
        };
      case 'a1_03':
        return {
          'sentence': "I will pay with contactless, and I don't need a bag, thanks!",
          'tokens': ['[I will pay]', '[with kahn-takt-les]', '[and I dohnt need]', '[a bag thanks]'],
          'tip': 'Ritmo suave en "and I don\'t need" sin detener el flujo de aire.',
        };
      case 'a1_04':
        return {
          'sentence': 'Excuse me, could you tell me which way to the train station?',
          'tokens': ['[ik-SKYOOS mee]', '[kood yoo tell mee]', '[which way to]', '[thuh trayn stay-shun]'],
          'tip': 'Entonación cortés ascendente al inicio y descendente al final.',
        };
      case 'a1_05':
        return {
          'sentence': "Hi, I'm checking in for two nights. The reservation is under Alex.",
          'tokens': ['[hy]', '[I\'m chek-ing in]', '[for too nyts]', '[un-der al-eks]'],
          'tip': 'Liaison natural: "checking in" suena unido como /tʃek.ɪŋ.ɪn/.',
        };
    }

    return {
      'sentence': 'I would really appreciate your guidance with this today.',
      'tokens': ['[I would ree-lee]', '[uh-PREE-shee-ayt]', '[yur GY-dens]', '[with this to-day]'],
      'tip': 'Acentúa claramente las palabras de contenido: "REALLY", "APPRECIATE", "GUIDANCE".',
    };
  }

  // =========================================================================
  // 6. LISTENING COMPREHENSION BUILDER
  // =========================================================================
  static ExerciseModel _buildListeningForTopic(ConversationTopicMeta topic) {
    final scenarios = [
      {
        'script': 'Attention passengers on flight two zero four to Chicago O\'Hare. Your departure gate has been relocated from B12 to C7 due to scheduled runway maintenance. Boarding commences in twenty minutes.',
        'question': '¿Hacia qué puerta deben dirigirse los pasajeros del vuelo 204?',
        'options': ['Puerta C7', 'Puerta B12', 'Puerta A14', 'Puerta D20'],
        'answer': 'Puerta C7',
        'trick': 'Truco Auditivo: "Has been relocated" indica el cambio de puerta asignada.',
      },
      {
        'script': 'Good afternoon! For your beverage today, I can prepare that iced latte with either organic oat milk or almond milk, and we have sugar-free hazelnut syrup.',
        'question': '¿Qué leches vegetales ofreció el barista en el audio?',
        'options': ['Avena orgánica o almendra', 'Soja o coco', 'Solo leche de vaca entera', 'Leche deslactosada'],
        'answer': 'Avena orgánica o almendra',
        'trick': 'Truco Auditivo: "Either... or..." expresa las dos opciones disponibles.',
      },
      {
        'script': 'According to the astrophysics briefing, the James Webb Space Telescope observes primarily in infrared because ancient light has redshifted across billions of years.',
        'question': '¿Por qué el telescopio espacial observa en luz infrarroja?',
        'options': [
          'Porque la luz antigua se ha desplazado al rojo',
          'Para ahorrar energía en el espacio profundo',
          'Porque el espacio exterior refleja luz ultravioleta',
          'Para captar únicamente la radiación lunar',
        ],
        'answer': 'Porque la luz antigua se ha desplazado al rojo',
        'trick': 'Truco Auditivo: "Redshifted" (corrimiento al rojo) es el fenómeno óptico clave.',
      },
      {
        'script': 'Doctor Martinez recommends taking two tablets strictly thirty minutes after your evening meal to prevent any gastric irritation.',
        'question': '¿Cuándo debe tomarse la medicación según el doctor?',
        'options': [
          '30 minutos después de la cena',
          'En ayunas por la mañana',
          'Inmediatamente antes de dormir con agua',
          'A cualquier hora del día',
        ],
        'answer': '30 minutos después de la cena',
        'trick': 'Truco Auditivo: "Strictly thirty minutes after your evening meal" indica el momento exacto.',
      },
      {
        'script': 'While the executive board appreciated the aggressive schedule, they voted to postpone the software launch until the second quarter to safeguard cybersecurity.',
        'question': '¿Qué decisión tomó la junta directiva respecto al lanzamiento?',
        'options': [
          'Postergarlo hasta el segundo trimestre',
          'Cancelar el proyecto de forma definitiva',
          'Lanzarlo esta misma semana sin cambios',
          'Vender la patente a un competidor',
        ],
        'answer': 'Postergarlo hasta el segundo trimestre',
        'trick': 'Truco Auditivo: "Voted to postpone... until the second quarter" expresa la decisión ejecutiva.',
      },
    ];

    final index = topic.id.hashCode.abs() % scenarios.length;
    final data = scenarios[index];

    return ExerciseModel(
      id: '${topic.id}_listening',
      type: DrillType.listeningComprehension,
      prompt: 'Escucha con atención y responde:',
      subtitle: 'Comprensión auditiva real con pronunciación nativa',
      trickTip: data['trick'] as String,
      audioScript: data['script'] as String,
      comprehensionQuestion: data['question'] as String,
      listeningOptions: List<String>.from(data['options'] as List),
      correctListeningAnswer: data['answer'] as String,
    );
  }

  // =========================================================================
  // 7. SCIENCE & REAL-WORLD CURIOSITY BUILDER
  // =========================================================================
  static ExerciseModel _buildScienceForTopic(ConversationTopicMeta topic) {
    final scienceFacts = [
      {
        'badge': '🧠 Neurociencia & Aprendizaje',
        'prompt': 'Lee el descubrimiento neurocientífico y analiza:',
        'subtitle': 'Vocabulario científico auténtico en contexto',
        'snippet': 'Neuroplasticity proves that adult brains continuously forge new neural pathways through deliberate spaced repetition and bilingual cognitive challenges.',
        'question': 'Según el texto científico, ¿cómo desarrolla el cerebro nuevas vías neuronales?',
        'options': [
          'Mediante repetición espaciada y desafíos bilingües',
          'Únicamente descansando ocho horas al día',
          'A través de mutaciones genéticas pasivas',
          'Solo durante los primeros cinco años de vida',
        ],
        'answer': 'Mediante repetición espaciada y desafíos bilingües',
        'trick': 'Vocabulario Científico: "To forge" significa forjar o construir conexiones sólidas.',
      },
      {
        'badge': '🪐 Astrofísica & Cosmología',
        'prompt': 'Analiza el informe astronómico sobre el cosmos:',
        'subtitle': 'Fenómenos del universo en inglés real',
        'snippet': 'Gravitational lensing occurs when a massive cluster of galaxies bends the spacetime fabric, acting like a colossal cosmic magnifying glass.',
        'question': '¿Qué provoca el efecto de "lente gravitacional" según el texto?',
        'options': [
          'La masa de las galaxias curva el tejido del espaciotiempo',
          'El viento solar en los polos magnéticos planetarios',
          'Los cristales de hielo en la atmósfera superior',
          'La colisión de dos agujeros negros supermasivos',
        ],
        'answer': 'La masa de las galaxias curva el tejido del espaciotiempo',
        'trick': 'Vocabulario Científico: "Bends the spacetime fabric" = curva el tejido espacio-temporal.',
      },
      {
        'badge': '🌊 Biología Marina & Bioquímica',
        'prompt': 'Descubre la adaptación de las criaturas abisales:',
        'subtitle': 'Ciencia biológica de vanguardia',
        'snippet': 'Deep-sea organisms produce bioluminescence via an enzymatic oxidation reaction between luciferin and oxygen, creating cold light without wasting thermal energy.',
        'question': '¿Cuál es la característica principal de la bioluminiscencia descrita?',
        'options': [
          'Genera luz fría sin desperdiciar energía térmica',
          'Emite calor extremo para ahuyentar a los depredadores',
          'Requiere luz solar directa para poder activarse',
          'Depende exclusivamente de descargas eléctricas constantes',
        ],
        'answer': 'Genera luz fría sin desperdiciar energía térmica',
        'trick': 'Vocabulario Científico: "Cold light without wasting thermal energy" es la notable eficiencia de la bioluminiscencia.',
      },
      {
        'badge': '⚡ Computación Cuántica',
        'prompt': 'Explora la física computacional cuántica:',
        'subtitle': 'Tecnología y computación moderna',
        'snippet': 'Unlike classical binary bits that exist strictly as zero or one, quantum qubits harness superposition, enabling them to calculate vast probabilities simultaneously.',
        'question': '¿Qué ventaja otorgan los qubits cuánticos gracias a la superposición?',
        'options': [
          'Calcular múltiples probabilidades de manera simultánea',
          'Consumir menos almacenamiento en discos duros tradicionales',
          'Funcionar sin necesidad de algoritmos de software',
          'Garantizar que no existan errores lógicos en el hardware',
        ],
        'answer': 'Calcular múltiples probabilidades de manera simultánea',
        'trick': 'Vocabulario Científico: "Harness superposition" = aprovechar la superposición cuántica.',
      },
    ];

    final index = topic.id.hashCode.abs() % scienceFacts.length;
    final item = scienceFacts[index];

    return ExerciseModel(
      id: '${topic.id}_science',
      type: DrillType.scienceFactContext,
      prompt: item['prompt'] as String,
      subtitle: item['subtitle'] as String,
      trickTip: item['trick'] as String,
      factBadge: item['badge'] as String,
      factSnippet: item['snippet'] as String,
      factQuestion: item['question'] as String,
      scienceOptions: List<String>.from(item['options'] as List),
      correctScienceAnswer: item['answer'] as String,
    );
  }

  // =========================================================================
  // 8. UNIT JUMP EXAM GENERATOR (DIFFICULT PLACEMENT CHALLENGE)
  // =========================================================================
  /// Generates a demanding 8-exercise Unit Jump Exam to skip the entire unit.
  /// Tests real grammar, listening comprehension, science analysis, and dialogue pragmatics.
  static List<ExerciseModel> generateJumpExamForUnit(int unitNumber) {
    final allTopics = ConversationTopicsCatalog.allTopics;
    final startIndex = (unitNumber - 1) * 6;
    final endIndex = (startIndex + 6 <= allTopics.length) ? startIndex + 6 : allTopics.length;
    final unitTopics = allTopics.sublist(startIndex, endIndex);

    final t1 = unitTopics.first;
    final t2 = unitTopics.length > 1 ? unitTopics[1] : t1;
    final t3 = unitTopics.length > 2 ? unitTopics[2] : t1;
    final t4 = unitTopics.length > 3 ? unitTopics[3] : t2;
    final t5 = unitTopics.length > 4 ? unitTopics[4] : t3;
    final tBoss = unitTopics.last;

    final List<ExerciseModel> exam = [];

    // 1. Strict Scramble Drill with extra distractors
    final sc1 = _buildScrambleForTopic(t1);
    exam.add(
      ExerciseModel(
        id: 'exam_u${unitNumber}_scramble_1',
        type: DrillType.sentenceScramble,
        prompt: '⚡ EXAMEN DE SALTO [1/8]: Reconstruye con sintaxis perfecta:',
        subtitle: '"${sc1['meaning']}" (Sin margen de error)',
        trickTip: sc1['trick'] as String,
        targetSentenceWords: List<String>.from(sc1['target'] as List),
        bankWords: List<String>.from(sc1['bank'] as List),
      ),
    );

    // 2. Strict Cloze Fill Drill
    final cl1 = _buildClozeForTopic(t2, LearnerWeakness.prepositions);
    exam.add(
      ExerciseModel(
        id: 'exam_u${unitNumber}_cloze_1',
        type: DrillType.clozeFill,
        prompt: '⚡ EXAMEN DE SALTO [2/8]: Precisión gramatical estricta:',
        subtitle: 'Tema evaluado: ${t2.title} (${t2.targetGrammar})',
        trickTip: cl1['trick'] as String,
        clozePrefix: cl1['prefix'] as String,
        clozeSuffix: cl1['suffix'] as String,
        clozeOptions: List<String>.from(cl1['options'] as List),
        correctClozeAnswer: cl1['answer'] as String,
      ),
    );

    // 3. Audio Listening Comprehension
    final list1 = _buildListeningForTopic(t3);
    exam.add(
      ExerciseModel(
        id: 'exam_u${unitNumber}_listening_1',
        type: DrillType.listeningComprehension,
        prompt: '⚡ EXAMEN DE SALTO [3/8]: Comprensión auditiva crítica:',
        subtitle: 'Escucha el audio nativo y detecta la respuesta exacta',
        trickTip: list1.trickTip,
        audioScript: list1.audioScript,
        comprehensionQuestion: list1.comprehensionQuestion,
        listeningOptions: list1.listeningOptions,
        correctListeningAnswer: list1.correctListeningAnswer,
      ),
    );

    // 4. Science & Curiosity Reading Challenge
    final sci1 = _buildScienceForTopic(t4);
    exam.add(
      ExerciseModel(
        id: 'exam_u${unitNumber}_science_1',
        type: DrillType.scienceFactContext,
        prompt: '⚡ EXAMEN DE SALTO [4/8]: Lectura e inferencia científica:',
        subtitle: sci1.subtitle,
        trickTip: sci1.trickTip,
        factBadge: sci1.factBadge,
        factSnippet: sci1.factSnippet,
        factQuestion: sci1.factQuestion,
        scienceOptions: sci1.scienceOptions,
        correctScienceAnswer: sci1.correctScienceAnswer,
      ),
    );

    // 5. Advanced Syllable Stress
    final str1 = _buildStressForTopic(t5);
    exam.add(
      ExerciseModel(
        id: 'exam_u${unitNumber}_stress_1',
        type: DrillType.syllableStress,
        prompt: '⚡ EXAMEN DE SALTO [5/8]: Identifica el acento prosódico:',
        subtitle: 'Enfoque fonético: ${t5.targetPhonemeFocus}',
        trickTip: str1['trick'] as String,
        ipaPhonetic: str1['ipa'] as String,
        syllables: List<String>.from(str1['syllables'] as List),
        correctSyllableIndex: str1['index'] as int,
      ),
    );

    // 6. Advanced Second Listening Comprehension
    final list2 = _buildListeningForTopic(tBoss);
    exam.add(
      ExerciseModel(
        id: 'exam_u${unitNumber}_listening_2',
        type: DrillType.listeningComprehension,
        prompt: '⚡ EXAMEN DE SALTO [6/8]: Prueba auditiva avanzada:',
        subtitle: 'Análisis de intención y colocación del hablante',
        trickTip: list2.trickTip,
        audioScript: list2.audioScript,
        comprehensionQuestion: list2.comprehensionQuestion,
        listeningOptions: list2.listeningOptions,
        correctListeningAnswer: list2.correctListeningAnswer,
      ),
    );

    // 7. Second Science Context Challenge
    final sci2 = _buildScienceForTopic(tBoss);
    exam.add(
      ExerciseModel(
        id: 'exam_u${unitNumber}_science_2',
        type: DrillType.scienceFactContext,
        prompt: '⚡ EXAMEN DE SALTO [7/8]: Análisis contextual complejo:',
        subtitle: 'Terminología y deducción lógica en inglés',
        trickTip: sci2.trickTip,
        factBadge: sci2.factBadge,
        factSnippet: sci2.factSnippet,
        factQuestion: sci2.factQuestion,
        scienceOptions: sci2.scienceOptions,
        correctScienceAnswer: sci2.correctScienceAnswer,
      ),
    );

    // 8. Pragmatic Choice Boss Dialogue
    final cho1 = _buildChoiceForTopic(tBoss);
    exam.add(
      ExerciseModel(
        id: 'exam_u${unitNumber}_choice_1',
        type: DrillType.pictureChoice,
        prompt: '⚡ EXAMEN DE SALTO [8/8]: Resolución conversacional final:',
        subtitle: 'Conversación de maestría con ${tBoss.npcName} (${tBoss.npcRole})',
        pictureOptions: List<PictureChoiceOption>.from(cho1['options'] as List),
      ),
    );

    return exam;
  }

  // =========================================================================
  // 9. STORY PASSAGE & ADVENTURE LORE BUILDER
  // =========================================================================
  static ExerciseModel _buildStoryPassageForTopic(ConversationTopicMeta topic) {
    final loreStories = [
      {
        'chapter': 'Capítulo 1: El Transmisor Secreto de la Casa del Árbol',
        'prompt': 'Completa el pasaje narrativo de la historia:',
        'subtitle': 'Aventura en Ooo • Lectura contextual y vocabulario',
        'leading': 'Finn and Jake discovered an ancient radio tucked beneath the treehouse floorboards. The copper antenna was glowing brightly, and a mysterious voice from across the multiverse whispered that true linguistic power is gained only by those who',
        'trailing': 'consistently every single day without fear of making mistakes.',
        'options': ['practice speaking', 'stop listening', 'sleep quietly', 'run away'],
        'answer': 'practice speaking',
        'trick': 'Lectura Contextual: "Practice speaking consistently" se enlaza con "linguistic power".',
      },
      {
        'chapter': 'Capítulo 2: La Fórmula de la Dulce Princesa',
        'prompt': 'Analiza el informe del laboratorio de Bubblegum:',
        'subtitle': 'Aventura en Ooo • Ciencia y precisión en inglés',
        'leading': 'Inside the Candy Kingdom royal observatory, Princess Bubblegum adjusted her goggles and held up a beaker filled with luminescent liquid. She explained to Finn that the experiment would fail unless they',
        'trailing': 'the ingredients with absolute scientific precision.',
        'options': ['measure', 'burn', 'forget', 'ignore'],
        'answer': 'measure',
        'trick': 'Lectura Contextual: "Measure the ingredients" es la colocación precisa requerida en el laboratorio.',
      },
      {
        'chapter': 'Capítulo 3: El Acorde Ancestral de Marceline',
        'prompt': 'Sigue el relato de la Cueva de los Ecos:',
        'subtitle': 'Aventura en Ooo • Comprensión lectora narrativa',
        'leading': 'Deep in the obsidian cavern, Marceline tuned the four steel strings of her battle-axe bass. As the sound resonated through the tunnels, she smiled and told Jake that every great song begins with someone who has the courage to',
        'trailing': 'their own authentic voice without hesitation.',
        'options': ['express', 'hide', 'destroy', 'dislike'],
        'answer': 'express',
        'trick': 'Lectura Contextual: "To express one\'s authentic voice" es una frase idiomática indispensable.',
      },
      {
        'chapter': 'Capítulo 4: El Algoritmo Cuántico de BMO',
        'prompt': 'Descifra la pantalla de BMO:',
        'subtitle': 'Aventura en Ooo • Tecnología del lore en inglés',
        'leading': 'BMO beeped cheerily and projected a holographic green map onto the wooden table. The robotic companion declared that the dimensional rift could be safely closed if the heroes could successfully',
        'trailing': 'the grammatical cipher before the midnight bell tolled.',
        'options': ['decode', 'erase', 'break', 'lose'],
        'answer': 'decode',
        'trick': 'Lectura Contextual: "Decode the cipher" (descifrar el código) es la acción narrativa clave.',
      },
      {
        'chapter': 'Capítulo 5: Los Manuscritos del Rey Helado',
        'prompt': 'Lee el fragmento hallado en la montaña de hielo:',
        'subtitle': 'Aventura en Ooo • Crónicas del pasado',
        'leading': 'Perched atop the frozen battlements, Simon opened a weather-worn diary written before the ancient catastrophe. The yellowed pages revealed that long ago, people from distant continents could easily',
        'trailing': 'with one another by learning a shared universal language.',
        'options': ['communicate', 'argue', 'disappear', 'sleep'],
        'answer': 'communicate',
        'trick': 'Lectura Contextual: "Communicate with one another" (comunicarse unos con otros).',
      },
    ];

    final index = topic.id.hashCode.abs() % loreStories.length;
    final item = loreStories[index];

    return ExerciseModel(
      id: '${topic.id}_story',
      type: DrillType.storyPassage,
      prompt: item['prompt'] as String,
      subtitle: item['subtitle'] as String,
      trickTip: item['trick'] as String,
      storyChapterTitle: item['chapter'] as String,
      storyPassageLeading: item['leading'] as String,
      storyPassageTrailing: item['trailing'] as String,
      storyOptions: List<String>.from(item['options'] as List),
      correctStoryAnswer: item['answer'] as String,
    );
  }
}
