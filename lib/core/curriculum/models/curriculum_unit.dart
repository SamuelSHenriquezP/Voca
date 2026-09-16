class CurriculumUnit {
  final UnitMetadata metadata;
  final List<CurriculumNode> nodes;

  const CurriculumUnit({
    required this.metadata,
    required this.nodes,
  });

  factory CurriculumUnit.fromJson(Map<String, dynamic> json) {
    return CurriculumUnit(
      metadata: UnitMetadata.fromJson(json['unit_metadata'] as Map<String, dynamic>),
      nodes: (json['nodes'] as List<dynamic>)
          .map((n) => CurriculumNode.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'unit_metadata': metadata.toJson(),
        'nodes': nodes.map((n) => n.toJson()).toList(),
      };
}

class UnitMetadata {
  final String unitId;
  final String cefrLevel;
  final String title;
  final String pedagogicalObjective;
  final String targetGrammar;
  final String targetPhonemeFocus;
  final List<VocabularyItem> newVocabulary;

  const UnitMetadata({
    required this.unitId,
    required this.cefrLevel,
    required this.title,
    required this.pedagogicalObjective,
    required this.targetGrammar,
    required this.targetPhonemeFocus,
    required this.newVocabulary,
  });

  factory UnitMetadata.fromJson(Map<String, dynamic> json) {
    return UnitMetadata(
      unitId: json['unit_id'] as String,
      cefrLevel: json['cefr_level'] as String,
      title: json['title'] as String,
      pedagogicalObjective: json['pedagogical_objective'] as String,
      targetGrammar: json['target_grammar'] as String,
      targetPhonemeFocus: json['target_phoneme_focus'] as String,
      newVocabulary: (json['new_vocabulary'] as List<dynamic>)
          .map((v) => VocabularyItem.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'unit_id': unitId,
        'cefr_level': cefrLevel,
        'title': title,
        'pedagogical_objective': pedagogicalObjective,
        'target_grammar': targetGrammar,
        'target_phoneme_focus': targetPhonemeFocus,
        'new_vocabulary': newVocabulary.map((v) => v.toJson()).toList(),
      };
}

class VocabularyItem {
  final String word;
  final String ipa;
  final String definitionEs;
  final String contextSentence;

  const VocabularyItem({
    required this.word,
    required this.ipa,
    required this.definitionEs,
    required this.contextSentence,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] as String,
      ipa: json['ipa'] as String,
      definitionEs: json['definition_es'] as String,
      contextSentence: json['context_sentence'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'ipa': ipa,
        'definition_es': definitionEs,
        'context_sentence': contextSentence,
      };
}

enum CurriculumNodeType {
  drillRecognition,
  drillSyntax,
  shadowingPhonetics,
  interactiveStory,
  bossFightCall,
}

class CurriculumNode {
  final String nodeId;
  final int nodeIndex;
  final CurriculumNodeType type;
  final String title;
  final List<dynamic>? exercises;
  final List<StoryTurn>? storyTurns;
  final BossFightScenario? scenario;

  const CurriculumNode({
    required this.nodeId,
    required this.nodeIndex,
    required this.type,
    required this.title,
    this.exercises,
    this.storyTurns,
    this.scenario,
  });

  factory CurriculumNode.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    CurriculumNodeType nodeType;
    switch (typeStr) {
      case 'drill_recognition':
        nodeType = CurriculumNodeType.drillRecognition;
        break;
      case 'drill_syntax':
        nodeType = CurriculumNodeType.drillSyntax;
        break;
      case 'shadowing_phonetics':
        nodeType = CurriculumNodeType.shadowingPhonetics;
        break;
      case 'interactive_story':
        nodeType = CurriculumNodeType.interactiveStory;
        break;
      case 'boss_fight_call':
      default:
        nodeType = CurriculumNodeType.bossFightCall;
        break;
    }

    return CurriculumNode(
      nodeId: json['node_id'] as String,
      nodeIndex: json['node_index'] as int,
      type: nodeType,
      title: json['title'] as String,
      exercises: json['exercises'] as List<dynamic>?,
      storyTurns: json['story_turns'] != null
          ? (json['story_turns'] as List<dynamic>)
              .map((st) => StoryTurn.fromJson(st as Map<String, dynamic>))
              .toList()
          : null,
      scenario: json['scenario'] != null
          ? BossFightScenario.fromJson(json['scenario'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'node_id': nodeId,
        'node_index': nodeIndex,
        'type': type.name,
        'title': title,
        if (exercises != null) 'exercises': exercises,
        if (storyTurns != null) 'story_turns': storyTurns!.map((s) => s.toJson()).toList(),
        if (scenario != null) 'scenario': scenario!.toJson(),
      };
}

class StoryTurn {
  final String speaker;
  final String text;
  final QuestionTrigger? questionTrigger;

  const StoryTurn({
    required this.speaker,
    required this.text,
    this.questionTrigger,
  });

  factory StoryTurn.fromJson(Map<String, dynamic> json) {
    return StoryTurn(
      speaker: json['speaker'] as String,
      text: json['text'] as String,
      questionTrigger: json['question_trigger'] != null
          ? QuestionTrigger.fromJson(json['question_trigger'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'speaker': speaker,
        'text': text,
        if (questionTrigger != null) 'question_trigger': questionTrigger!.toJson(),
      };
}

class QuestionTrigger {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuestionTrigger({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuestionTrigger.fromJson(Map<String, dynamic> json) {
    return QuestionTrigger(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correct_index'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correct_index': correctIndex,
      };
}

class BossFightScenario {
  final String npcName;
  final String npcRole;
  final String npcPersonality;
  final String npcInitialAudioGreeting;
  final String systemPromptForAi;
  final List<String> missionGoals;
  final List<String> vocabularyRequiredToWin;
  final String successCriteriaSummary;

  const BossFightScenario({
    required this.npcName,
    required this.npcRole,
    required this.npcPersonality,
    required this.npcInitialAudioGreeting,
    required this.systemPromptForAi,
    required this.missionGoals,
    required this.vocabularyRequiredToWin,
    required this.successCriteriaSummary,
  });

  factory BossFightScenario.fromJson(Map<String, dynamic> json) {
    return BossFightScenario(
      npcName: json['npc_name'] as String,
      npcRole: json['npc_role'] as String,
      npcPersonality: json['npc_personality'] as String,
      npcInitialAudioGreeting: json['npc_initial_audio_greeting'] as String,
      systemPromptForAi: json['system_prompt_for_ai'] as String,
      missionGoals: List<String>.from(json['mission_goals'] as List),
      vocabularyRequiredToWin: List<String>.from(json['vocabulary_required_to_win'] as List),
      successCriteriaSummary: json['success_criteria_summary'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'npc_name': npcName,
        'npc_role': npcRole,
        'npc_personality': npcPersonality,
        'npc_initial_audio_greeting': npcInitialAudioGreeting,
        'system_prompt_for_ai': systemPromptForAi,
        'mission_goals': missionGoals,
        'vocabulary_required_to_win': vocabularyRequiredToWin,
        'success_criteria_summary': successCriteriaSummary,
      };
}
