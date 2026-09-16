import 'package:flutter/material.dart';

enum CardType { attack, defense, skill, power }
enum CardRarity { starter, common, rare, legendary }

class CardCriticalDrill {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const CardCriticalDrill({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class LinguisticCard {
  final String id;
  final String name;
  final String phrase;
  final String ipa;
  final CardType type;
  final CardRarity rarity;
  final String cefrLevel;
  final int energyCost;
  final int damage;
  final int block;
  final String description;
  final CardCriticalDrill drill;

  const LinguisticCard({
    required this.id,
    required this.name,
    required this.phrase,
    required this.ipa,
    required this.type,
    required this.rarity,
    required this.cefrLevel,
    required this.energyCost,
    this.damage = 0,
    this.block = 0,
    required this.description,
    required this.drill,
  });

  Color get rarityColor {
    switch (rarity) {
      case CardRarity.starter:
        return const Color(0xFF64748B);
      case CardRarity.common:
        return const Color(0xFF0284C7);
      case CardRarity.rare:
        return const Color(0xFFD97706);
      case CardRarity.legendary:
        return const Color(0xFF7C3AED);
    }
  }

  Color get typeColor {
    switch (type) {
      case CardType.attack:
        return const Color(0xFFE11D48); // Red Crimson
      case CardType.defense:
        return const Color(0xFF0284C7); // Cyan Shield
      case CardType.skill:
        return const Color(0xFF059669); // Emerald Energy
      case CardType.power:
        return const Color(0xFF7C3AED); // Royal Purple
    }
  }

  IconData get typeIcon {
    switch (type) {
      case CardType.attack:
        return Icons.flash_on_rounded;
      case CardType.defense:
        return Icons.shield_rounded;
      case CardType.skill:
        return Icons.auto_awesome_rounded;
      case CardType.power:
        return Icons.all_inclusive_rounded;
    }
  }
}

class DeckCatalog {
  // --- STARTER DECK ---
  static const List<LinguisticCard> starterDeck = [
    LinguisticCard(
      id: 'card_strike_1',
      name: 'Verbal Strike',
      phrase: 'I get it',
      ipa: '/aɪ ɡet ɪt/',
      type: CardType.attack,
      rarity: CardRarity.starter,
      cefrLevel: 'A1',
      energyCost: 1,
      damage: 6,
      description: 'Deal 6 linguistic damage. Quick comprehension strike.',
      drill: CardCriticalDrill(
        prompt: 'What does "I get it" mean in conversation?',
        options: ['I understand', 'I buy it', 'I lose it'],
        correctIndex: 0,
        explanation: '"Get" is widely used in spoken English to mean understand.',
      ),
    ),
    LinguisticCard(
      id: 'card_strike_2',
      name: 'Verbal Strike',
      phrase: 'No way',
      ipa: '/noʊ weɪ/',
      type: CardType.attack,
      rarity: CardRarity.starter,
      cefrLevel: 'A1',
      energyCost: 1,
      damage: 6,
      description: 'Deal 6 linguistic damage.',
      drill: CardCriticalDrill(
        prompt: '"No way!" expresses:',
        options: ['Disbelief / Surprise', 'Directions', 'Agreement'],
        correctIndex: 0,
        explanation: 'Natural conversational expression of surprise or refusal.',
      ),
    ),
    LinguisticCard(
      id: 'card_defend_1',
      name: 'Phonetic Guard',
      phrase: 'Hold on',
      ipa: '/hoʊld ɑːn/',
      type: CardType.defense,
      rarity: CardRarity.starter,
      cefrLevel: 'A1',
      energyCost: 1,
      block: 5,
      description: 'Gain 5 Block. Grants time to formulate your response.',
      drill: CardCriticalDrill(
        prompt: 'Which phrasal verb means the same as "Hold on"?',
        options: ['Wait a moment', 'Carry on', 'Give up'],
        correctIndex: 0,
        explanation: '"Hold on" is the natural spoken form of "wait".',
      ),
    ),
    LinguisticCard(
      id: 'card_defend_2',
      name: 'Phonetic Guard',
      phrase: 'Let me think',
      ipa: '/let miː θɪŋk/',
      type: CardType.defense,
      rarity: CardRarity.starter,
      cefrLevel: 'A1',
      energyCost: 1,
      block: 5,
      description: 'Gain 5 Block. A strategic pause filler.',
      drill: CardCriticalDrill(
        prompt: 'Which phonetic sound starts the word "think"?',
        options: ['/θ/ (unvoiced)', '/ð/ (voiced)', '/s/ (sibilant)'],
        correctIndex: 0,
        explanation: '"Think" uses the unvoiced dental fricative /θ/.',
      ),
    ),
    LinguisticCard(
      id: 'card_skill_1',
      name: 'Cadence Spark',
      phrase: 'By the way',
      ipa: '/baɪ ðə weɪ/',
      type: CardType.skill,
      rarity: CardRarity.starter,
      cefrLevel: 'A1',
      energyCost: 1,
      description: 'Draw 2 cards. Smooth topic transition.',
      drill: CardCriticalDrill(
        prompt: 'When do speakers use "By the way"?',
        options: ['To introduce related info', 'To say goodbye', 'To disagree strongly'],
        correctIndex: 0,
        explanation: 'Used as an organic conversational pivot.',
      ),
    ),
  ];

  // --- REWARD DRAFTING POOL (30+ CARDS) ---
  static const List<LinguisticCard> rewardPool = [
    // A1 - A2 Cards
    LinguisticCard(
      id: 'card_piece_of_cake',
      name: 'Cake Slice Slash',
      phrase: 'Piece of cake',
      ipa: '/piːs əv keɪk/',
      type: CardType.attack,
      rarity: CardRarity.common,
      cefrLevel: 'A2',
      energyCost: 1,
      damage: 9,
      description: 'Deal 9 damage. Represents effortless mastery.',
      drill: CardCriticalDrill(
        prompt: '"This task is a piece of cake" means:',
        options: ['It is very easy', 'It is delicious', 'It is confusing'],
        correctIndex: 0,
        explanation: 'Classic spoken idiom for something trivial to accomplish.',
      ),
    ),
    LinguisticCard(
      id: 'card_break_a_leg',
      name: 'Thespian Thrust',
      phrase: 'Break a leg',
      ipa: '/breɪk ə leɡ/',
      type: CardType.attack,
      rarity: CardRarity.common,
      cefrLevel: 'A2',
      energyCost: 1,
      damage: 10,
      description: 'Deal 10 damage. Wishing good fortune with vigor.',
      drill: CardCriticalDrill(
        prompt: 'When do you say "Break a leg"?',
        options: ['Before a performance', 'In a hospital', 'During an apology'],
        correctIndex: 0,
        explanation: 'Traditional theater superstition wishing success.',
      ),
    ),
    LinguisticCard(
      id: 'card_call_it_a_day',
      name: 'Dusk Aegis',
      phrase: 'Call it a day',
      ipa: '/kɔːl ɪt ə deɪ/',
      type: CardType.defense,
      rarity: CardRarity.common,
      cefrLevel: 'A2',
      energyCost: 2,
      block: 12,
      description: 'Gain 12 Block. End exertion and consolidate position.',
      drill: CardCriticalDrill(
        prompt: '"Let us call it a day" signifies:',
        options: ['Stop working for today', 'Start an interview', 'Schedule a meeting'],
        correctIndex: 0,
        explanation: 'Idiom used to conclude work or a session.',
      ),
    ),
    LinguisticCard(
      id: 'card_catch_up',
      name: 'Rhythm Sync',
      phrase: 'Catch up',
      ipa: '/kætʃ ʌp/',
      type: CardType.skill,
      rarity: CardRarity.common,
      cefrLevel: 'A2',
      energyCost: 1,
      description: 'Gain 1 Energy and draw 1 card.',
      drill: CardCriticalDrill(
        prompt: '"Let\'s catch up soon" means:',
        options: ['Exchange recent news', 'Run faster', 'Finish homework'],
        correctIndex: 0,
        explanation: 'Key pragmatic phrase for reconnecting with friends.',
      ),
    ),
    LinguisticCard(
      id: 'card_hit_the_nail',
      name: 'Pinpoint Strike',
      phrase: 'Hit the nail on the head',
      ipa: '/hɪt ðə neɪl ɑːn ðə hed/',
      type: CardType.attack,
      rarity: CardRarity.rare,
      cefrLevel: 'B1',
      energyCost: 2,
      damage: 16,
      description: 'Deal 16 damage. Uncanny exactness in argumentation.',
      drill: CardCriticalDrill(
        prompt: 'To "hit the nail on the head" means to be:',
        options: ['Exactly right', 'Physically clumsy', 'Aggressive'],
        correctIndex: 0,
        explanation: 'Describing a statement that identifies the exact truth.',
      ),
    ),
    LinguisticCard(
      id: 'card_cut_corners',
      name: 'Reckless Gambit',
      phrase: 'Cut corners',
      ipa: '/kʌt ˈkɔːr.nɚz/',
      type: CardType.attack,
      rarity: CardRarity.rare,
      cefrLevel: 'B1',
      energyCost: 1,
      damage: 14,
      block: -3,
      description: 'Deal 14 damage, but lose 3 Block this turn.',
      drill: CardCriticalDrill(
        prompt: '"Cutting corners" implies:',
        options: ['Doing things cheaply/poorly', 'Drawing shapes', 'Saving time cleanly'],
        correctIndex: 0,
        explanation: 'Doing something in an easy or cheap way that sacrifices quality.',
      ),
    ),
    LinguisticCard(
      id: 'card_blessing_in_disguise',
      name: 'Fortuitous Pivot',
      phrase: 'A blessing in disguise',
      ipa: '/ə ˈbles.ɪŋ ɪn dɪsˈɡaɪz/',
      type: CardType.defense,
      rarity: CardRarity.rare,
      cefrLevel: 'B1',
      energyCost: 2,
      block: 15,
      description: 'Gain 15 Block. An apparent setback becomes an advantage.',
      drill: CardCriticalDrill(
        prompt: 'A "blessing in disguise" is:',
        options: ['A misfortune with a good outcome', 'A costume', 'An unavoidable tragedy'],
        correctIndex: 0,
        explanation: 'Something that seems bad at first but results in something good.',
      ),
    ),
    LinguisticCard(
      id: 'card_burn_midnight_oil',
      name: 'Overtime Engine',
      phrase: 'Burn the midnight oil',
      ipa: '/bɝːn ðə ˈmɪd.naɪt ɔɪl/',
      type: CardType.power,
      rarity: CardRarity.rare,
      cefrLevel: 'B1',
      energyCost: 2,
      description: 'At the start of each turn, draw 1 additional card.',
      drill: CardCriticalDrill(
        prompt: 'To "burn the midnight oil" means:',
        options: ['Work late into the night', 'Waste fuel', 'Cook after midnight'],
        correctIndex: 0,
        explanation: 'To study or work until very late at night.',
      ),
    ),
    LinguisticCard(
      id: 'card_nevertheless',
      name: 'Discourse Ward',
      phrase: 'Nevertheless',
      ipa: '/ˌnev.ɚ.ðəˈles/',
      type: CardType.defense,
      rarity: CardRarity.common,
      cefrLevel: 'B1',
      energyCost: 1,
      block: 8,
      description: 'Gain 8 Block. Negates adversarial counterarguments.',
      drill: CardCriticalDrill(
        prompt: '"Nevertheless" is synonymous with:',
        options: ['In spite of that / However', 'Because of that', 'Immediately'],
        correctIndex: 0,
        explanation: 'High-frequency formal transition marker of contrast.',
      ),
    ),
    LinguisticCard(
      id: 'card_spill_the_beans',
      name: 'Confession Burst',
      phrase: 'Spill the beans',
      ipa: '/spɪl ðə biːnz/',
      type: CardType.attack,
      rarity: CardRarity.common,
      cefrLevel: 'A2',
      energyCost: 1,
      damage: 11,
      description: 'Deal 11 damage. Reveals enemy intentions.',
      drill: CardCriticalDrill(
        prompt: '"Spill the beans" means to:',
        options: ['Disclose a secret', 'Drop food', 'Make coffee'],
        correctIndex: 0,
        explanation: 'Spoken idiom for revealing confidential information.',
      ),
    ),
    LinguisticCard(
      id: 'card_once_in_a_blue_moon',
      name: 'Celestial Nova',
      phrase: 'Once in a blue moon',
      ipa: '/wʌns ɪn ə bluː muːn/',
      type: CardType.attack,
      rarity: CardRarity.legendary,
      cefrLevel: 'B2',
      energyCost: 3,
      damage: 28,
      description: 'Deal 28 heavy damage. Rare and devastating impact.',
      drill: CardCriticalDrill(
        prompt: '"Once in a blue moon" describes events that occur:',
        options: ['Extremely rarely', 'Every month', 'During eclipses'],
        correctIndex: 0,
        explanation: 'Refers to something that happens on very infrequent occasions.',
      ),
    ),
    LinguisticCard(
      id: 'card_second_to_none',
      name: 'Pinnacle Aura',
      phrase: 'Second to none',
      ipa: '/ˈsek.ənd tuː nʌn/',
      type: CardType.power,
      rarity: CardRarity.legendary,
      cefrLevel: 'B2',
      energyCost: 3,
      description: 'Increases all attack card damage by +4 permanently for this combat.',
      drill: CardCriticalDrill(
        prompt: 'If a speaker is "second to none", they are:',
        options: ['The absolute best', 'Runner up', 'Inferior'],
        correctIndex: 0,
        explanation: 'Unrivaled excellence in quality or capability.',
      ),
    ),
    LinguisticCard(
      id: 'card_devil_advocate',
      name: 'Socratic Inversion',
      phrase: "Play devil's advocate",
      ipa: '/pleɪ ˈdev.əlz ˈæd.və.kət/',
      type: CardType.skill,
      rarity: CardRarity.rare,
      cefrLevel: 'B2',
      energyCost: 1,
      description: 'Gain 7 Block and draw 2 cards.',
      drill: CardCriticalDrill(
        prompt: 'To "play devil\'s advocate" means to:',
        options: ['Argue an opposing point for debate', 'Be evil', 'Reject evidence'],
        correctIndex: 0,
        explanation: 'Taking an opposite stance to test argument validity.',
      ),
    ),
    LinguisticCard(
      id: 'card_under_the_weather',
      name: 'Immunity Shield',
      phrase: 'Under the weather',
      ipa: '/ˈʌn.dɚ ðə ˈweð.ɚ/',
      type: CardType.defense,
      rarity: CardRarity.common,
      cefrLevel: 'A2',
      energyCost: 1,
      block: 7,
      description: 'Gain 7 Block. Acknowledges fatigue without yielding.',
      drill: CardCriticalDrill(
        prompt: 'Feeling "under the weather" means:',
        options: ['Slightly unwell or tired', 'Caught in rain', 'Depressed'],
        correctIndex: 0,
        explanation: 'Polite spoken way to express feeling mildly sick.',
      ),
    ),
  ];

  static List<LinguisticCard> getRandomRewards(int count) {
    final pool = List<LinguisticCard>.from(rewardPool)..shuffle();
    return pool.take(count).toList();
  }
}
