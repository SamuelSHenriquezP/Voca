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

  /// Generates a pedagogically rigorous 5-exercise lesson
  /// tailored directly to the specified topic, target grammar, vocabulary, and phonetics.
  static List<ExerciseModel> generateAdaptiveLessonForTopic(String topicId) {
    final topic = ConversationTopicsCatalog.getTopicById(topicId) ??
        ConversationTopicsCatalog.allTopics.first;

    final weakness = dominantWeakness;
    final List<ExerciseModel> exercises = [];

    // 1. Scramble Drill (Target syntax & grammar of the specific topic)
    final scrambleData = _buildScrambleForTopic(topic);
    exercises.add(
      ExerciseModel(
        id: '${topic.id}_scramble',
        type: DrillType.sentenceScramble,
        prompt: 'Organiza la oración para expresar:',
        subtitle: '"${scrambleData['meaning']}"',
        trickTip: scrambleData['trick'] as String,
        targetSentenceWords: List<String>.from(scrambleData['target'] as List),
        bankWords: List<String>.from(scrambleData['bank'] as List),
      ),
    );

    // 2. Cloze Fill Drill (Target grammar slot / preposition / collocation)
    final clozeData = _buildClozeForTopic(topic, weakness);
    exercises.add(
      ExerciseModel(
        id: '${topic.id}_cloze',
        type: DrillType.clozeFill,
        prompt: 'Completa la frase con la opción correcta:',
        subtitle: 'Tema: ${topic.title} (${topic.targetGrammar})',
        trickTip: clozeData['trick'] as String,
        clozePrefix: clozeData['prefix'] as String,
        clozeSuffix: clozeData['suffix'] as String,
        clozeOptions: List<String>.from(clozeData['options'] as List),
        correctClozeAnswer: clozeData['answer'] as String,
      ),
    );

    // 3. Syllable Stress Rhythm Drill (Target phoneme & stress)
    final stressData = _buildStressForTopic(topic);
    exercises.add(
      ExerciseModel(
        id: '${topic.id}_stress',
        type: DrillType.syllableStress,
        prompt: 'Toca la sílaba tónica (acento principal):',
        subtitle: 'Enfoque fonético: ${topic.targetPhonemeFocus}',
        trickTip: stressData['trick'] as String,
        ipaPhonetic: stressData['ipa'] as String,
        syllables: List<String>.from(stressData['syllables'] as List),
        correctSyllableIndex: stressData['index'] as int,
      ),
    );

    // 4. Picture & Meaning Choice Drill (Authentic pragmatic response)
    final choiceData = _buildChoiceForTopic(topic);
    exercises.add(
      ExerciseModel(
        id: '${topic.id}_choice',
        type: DrillType.pictureChoice,
        prompt: choiceData['prompt'] as String,
        subtitle: 'Respuesta conversacional con ${topic.npcName} (${topic.npcRole})',
        pictureOptions: List<PictureChoiceOption>.from(choiceData['options'] as List),
      ),
    );

    // 5. Shadowing Drill (Spoken rhythm & fluency)
    final shadowData = _buildShadowForTopic(topic);
    exercises.add(
      ExerciseModel(
        id: '${topic.id}_shadow',
        type: DrillType.shadowing,
        prompt: 'Pronuncia en voz alta con entonación natural:',
        targetSpeechText: '"${shadowData['sentence']}"',
        phoneticTokens: List<String>.from(shadowData['tokens'] as List),
        expectedAccentTip: shadowData['tip'] as String,
      ),
    );

    return exercises;
  }

  // =========================================================================
  // 1. SCRAMBLE BUILDER (TOPIC-SPECIFIC REAL GRAMMAR)
  // =========================================================================
  static Map<String, dynamic> _buildScrambleForTopic(ConversationTopicMeta topic) {
    // Curated exact mappings for foundation topics
    switch (topic.id) {
      case 'a1_01':
        return {
          'meaning': 'Hola, mi nombre es Alex y me alegro de conocerte.',
          'target': ['Hello,', 'my', 'name', 'is', 'Alex', 'and', 'I', 'am', 'glad', 'to', 'meet', 'you.'],
          'bank': ['nice', 'Alex', 'Hello,', 'is', 'meet', 'glad', 'to', 'I', 'you.', 'my', 'name', 'am', 'they', 'are'],
          'trick': 'Truco Nativo: "Glad to meet you" o "Nice to meet you" es la frase imprescindible para romper el hielo.',
        };
      case 'a1_02':
        return {
          'meaning': '¿Podría pedir un café con leche caliente para llevar, por favor?',
          'target': ['Could', 'I', 'please', 'get', 'a', 'hot', 'latte', 'to', 'go?'],
          'bank': ['latte', 'hot', 'Could', 'I', 'cup', 'to', 'go?', 'please', 'get', 'a', 'want', 'water'],
          'trick': 'Truco Nativo: En inglés americano de cafetería siempre se dice "to go" (para llevar), nunca "for go".',
        };
      case 'a1_03':
        return {
          'meaning': 'Pagaré con mi tarjeta de crédito hoy, muchas gracias.',
          'target': ['I', 'will', 'pay', 'with', 'my', 'credit', 'card', 'today,', 'thanks.'],
          'bank': ['credit', 'pay', 'card', 'with', 'I', 'will', 'today,', 'thanks.', 'money', 'cash'],
          'trick': 'Truco Nativo: "Pay with [card]" o "pay by card" son las colocaciones estándar al pagar.',
        };
      case 'a1_04':
        return {
          'meaning': 'Siga derecho por dos cuadras y doble a la izquierda en la esquina.',
          'target': ['Go', 'straight', 'for', 'two', 'blocks', 'and', 'turn', 'left.'],
          'bank': ['blocks', 'turn', 'Go', 'left.', 'straight', 'for', 'right', 'two', 'and', 'run'],
          'trick': 'Truco Nativo: Para direcciones se usan imperativos directos: "Go straight", "Turn left".',
        };
      case 'a1_05':
        return {
          'meaning': 'Tengo una reserva a nombre de Miller por dos noches.',
          'target': ['I', 'have', 'a', 'reservation', 'under', 'the', 'name', 'of', 'Miller.'],
          'bank': ['reservation', 'name', 'I', 'have', 'under', 'the', 'of', 'Miller.', 'a', 'room', 'hotel'],
          'trick': 'Truco Nativo: En hoteles se dice "under the name of..." para indicar el titular de la reserva.',
        };
      case 'a1_06':
        return {
          'meaning': '¿Puedo pedir el combo número dos con salsa barbacoa extra?',
          'target': ['Can', 'I', 'have', 'combo', 'number', 'two', 'with', 'extra', 'sauce?'],
          'bank': ['combo', 'two', 'Can', 'I', 'have', 'number', 'sauce?', 'with', 'extra', 'fries', 'soda'],
          'trick': 'Truco Nativo: "Can I have combo number..." es la forma más rápida y natural en ventanillas.',
        };
      case 'a1_07':
        return {
          'meaning': 'Reunámonos en la biblioteca a las cuatro y media en punto.',
          'target': ['Let', 'us', 'meet', 'at', 'the', 'library', 'at', 'half', 'past', 'four.'],
          'bank': ['meet', 'half', 'Let', 'us', 'at', 'library', 'the', 'past', 'four.', 'in', 'on'],
          'trick': 'Truco Nativo: Con horas exactas siempre usamos la preposición "at" (ej: at half past four).',
        };
      case 'a1_08':
        return {
          'meaning': '¿Cuánto cuesta una tarjeta de metro para viajar hoy?',
          'target': ['How', 'much', 'does', 'a', 'metro', 'card', 'cost', 'today?'],
          'bank': ['much', 'cost', 'How', 'metro', 'card', 'does', 'a', 'today?', 'many', 'fare'],
          'trick': 'Truco Nativo: Para precios incontables usamos siempre "How much does... cost?".',
        };
      case 'a1_09':
        return {
          'meaning': '¿Podría probarme esta camisa azul en una talla mediana?',
          'target': ['Could', 'I', 'try', 'on', 'this', 'blue', 'shirt', 'in', 'medium?'],
          'bank': ['try', 'blue', 'Could', 'I', 'on', 'this', 'medium?', 'shirt', 'in', 'wear', 'large'],
          'trick': 'Truco Nativo: El phrasal verb separable para ropa es "try on" (probarse).',
        };
      case 'a1_10':
        return {
          'meaning': 'Mi hermano mayor vive en Londres y tiene dos perros.',
          'target': ['My', 'older', 'brother', 'lives', 'in', 'London', 'and', 'has', 'dogs.'],
          'bank': ['lives', 'brother', 'My', 'older', 'has', 'in', 'London', 'and', 'dogs.', 'have', 'live'],
          'trick': 'Truco Nativo: En tercera persona singular (he/she) añadimos "-s" al verbo: "he lives", "he has".',
        };
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
}
