import 'package:flutter/material.dart';

class BiomeStory {
  final int biomeIndex;
  final String name;
  final String subtitle;
  final String cefrTier;
  final String loreDescription;
  final Color primaryColor;
  final Color secondaryColor;
  final String bossName;
  final String bossTitle;
  final String bossLore;

  const BiomeStory({
    required this.biomeIndex,
    required this.name,
    required this.subtitle,
    required this.cefrTier,
    required this.loreDescription,
    required this.primaryColor,
    required this.secondaryColor,
    required this.bossName,
    required this.bossTitle,
    required this.bossLore,
  });

  static const List<BiomeStory> biomes = [
    BiomeStory(
      biomeIndex: 1,
      name: 'The Whispering Shallows',
      subtitle: 'Valley of Phonetic Foundations',
      cefrTier: 'A1 - ELEMENTARY',
      loreDescription:
          'A misty wetland where broken syllables drift upon the wind. Here, silence has frozen the words of travelers. Only by mastering fundamental phonemes and essential survival phrases can you disperse the fog and awaken the path.',
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF38BDF8),
      bossName: 'The Monotone Warden',
      bossTitle: 'Guardian of Rigid Syllables',
      bossLore:
          'A stone automaton constructed by ancient scribes who spoke without pitch or rhythm. He enforces dull robotic speech. To overcome him, you must unlock natural intonation and vibrant vowel contrasts.',
    ),
    BiomeStory(
      biomeIndex: 2,
      name: 'The Crossroads of Idioms',
      subtitle: 'Bazaar of Connected Speech',
      cefrTier: 'A2 - PRE-INTERMEDIATE',
      loreDescription:
          'An overgrown commercial city where language becomes alive and rapid. Sentences fuse together through elision and linking. Rigid literal translations crumble here; only those who wield phrasal verbs and natural contractions can barter forward.',
      primaryColor: Color(0xFF059669),
      secondaryColor: Color(0xFF34D399),
      bossName: 'The Redundant Colossus',
      bossTitle: 'Devourer of Wordiness',
      bossLore:
          'A giant armored with heavy archaic dictionaries. He strikes whenever a speaker uses clunky textbook constructions instead of fluid natural collocations.',
    ),
    BiomeStory(
      biomeIndex: 3,
      name: 'The Citadel of Debate',
      subtitle: 'Fortress of Nuance & Rhetoric',
      cefrTier: 'B1 - INTERMEDIATE',
      loreDescription:
          'High marble spires hovering above thunderous clouds. Here, arguments clash like blades. Every clause requires precise discourse markers, modal conditionals, and persuasive clarity to withstand rhetorical gales.',
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFFFBBF24),
      bossName: 'The Sphinx of Ambiguity',
      bossTitle: 'Architect of Vague Intent',
      bossLore:
          'A mythical winged entity whose riddles twist meaning with misleading conjunctions. Only airtight logic and nuanced discourse connectors can pierce her illusions.',
    ),
    BiomeStory(
      biomeIndex: 4,
      name: 'The Celestial Spire of Fluency',
      subtitle: 'Summit of Pragmatic Mastery',
      cefrTier: 'B2 - UPPER-INTERMEDIATE',
      loreDescription:
          'The pinnacle of the Spoken Realm where thought dissolves directly into effortless spoken stream. Words move with spontaneous grace, cultural irony, and deep rhetorical resonance.',
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFFA78BFA),
      bossName: 'The Echo Master',
      bossTitle: 'Avatar of Native Cadence',
      bossLore:
          'The ultimate guardian of the Voice. He wields the rhythmic pulse of native speech, testing your reaction time, shadowing velocity, and mastery over complex idiomatic expressions in rapid verbal duels.',
    ),
  ];

  static BiomeStory getForFloor(int floor) {
    if (floor <= 3) return biomes[0];
    if (floor <= 6) return biomes[1];
    if (floor <= 9) return biomes[2];
    return biomes[3];
  }
}

class MysteryEventChoice {
  final String label;
  final String outcomeDescription;
  final int healthChange;
  final int scoreChange;
  final String? cardRewardId;
  final String? relicRewardId;

  const MysteryEventChoice({
    required this.label,
    required this.outcomeDescription,
    this.healthChange = 0,
    this.scoreChange = 0,
    this.cardRewardId,
    this.relicRewardId,
  });
}

class MysteryStoryEvent {
  final String id;
  final String title;
  final String locationName;
  final String storyPrompt;
  final List<MysteryEventChoice> choices;

  const MysteryStoryEvent({
    required this.id,
    required this.title,
    required this.locationName,
    required this.storyPrompt,
    required this.choices,
  });

  static const List<MysteryStoryEvent> allEvents = [
    MysteryStoryEvent(
      id: 'event_whispering_well',
      title: 'The Well of Forgotten Echoes',
      locationName: 'Sunken Shrine of Phonetics',
      storyPrompt:
          'You peer into a subterranean stone basin carved with ancient IPA phonetic runes. A faint vocal reverberation asks: "Will you sacrifice stamina to sharpen your acoustic ears, or draw the water to soothe your throat?"',
      choices: [
        MysteryEventChoice(
          label: 'Drink the crystalline water (+2 Hearts)',
          outcomeDescription:
              'The cool mineral water revitalizes your vocal cords. Your breathing stabilizes.',
          healthChange: 2,
          scoreChange: 50,
        ),
        MysteryEventChoice(
          label: 'Attune your hearing to the depth (+150 XP, -1 Heart)',
          outcomeDescription:
              'The intense acoustic feedback stuns your head, but your auditory perception expands dramatically.',
          healthChange: -1,
          scoreChange: 150,
        ),
      ],
    ),
    MysteryStoryEvent(
      id: 'event_wandering_lexicographer',
      title: 'The Wandering Lexicographer',
      locationName: 'The Roadside Library Caravan',
      storyPrompt:
          'A traveler draped in parchment scrolls adjusts his bronze spectacles. "I am collecting spoken idioms from ancient spoken dialects. Let us trade: share your energy, and I will grant you a powerful syntactic weapon."',
      choices: [
        MysteryEventChoice(
          label: 'Study his ancient scrolls (+200 XP)',
          outcomeDescription:
              'You memorize high-yield discourse connectors and idiomatic phrasing structures.',
          scoreChange: 200,
        ),
        MysteryEventChoice(
          label: 'Politely decline and preserve your vitality',
          outcomeDescription:
              'You exchange brief courtesy greetings and continue along the expedition path.',
          scoreChange: 25,
        ),
      ],
    ),
    MysteryStoryEvent(
      id: 'event_altar_of_rhythm',
      title: 'The Monolith of Cadence',
      locationName: 'Pinnacle Overlook',
      storyPrompt:
          'A colossal tuning fork vibrates at precisely 432Hz in the mountain wind. Touching it causes your vocal cords to hum in sync with the natural rhythm of English sentence stress.',
      choices: [
        MysteryEventChoice(
          label: 'Chant in rhythm with the monolith (+1 Heart, +100 XP)',
          outcomeDescription:
              'Your speech rhythm locks into native syllable-timed patterns.',
          healthChange: 1,
          scoreChange: 100,
        ),
        MysteryEventChoice(
          label: 'Strike the monolith for a sound burst (+250 XP, -1 Heart)',
          outcomeDescription:
              'A shockwave of sound reverberates through your chest, imparting deep acoustic insight.',
          healthChange: -1,
          scoreChange: 250,
        ),
      ],
    ),
  ];
}

