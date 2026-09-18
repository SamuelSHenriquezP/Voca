import 'package:flutter/material.dart';

enum RelicRarity { common, rare, legendary }

class LinguisticRelic {
  final String id;
  final String name;
  final RelicRarity rarity;
  final String description;
  final String flavorLore;
  final IconData icon;

  const LinguisticRelic({
    required this.id,
    required this.name,
    required this.rarity,
    required this.description,
    required this.flavorLore,
    required this.icon,
  });

  Color get color {
    switch (rarity) {
      case RelicRarity.common:
        return const Color(0xFF64748B); // Slate
      case RelicRarity.rare:
        return const Color(0xFFD97706); // Amber
      case RelicRarity.legendary:
        return const Color(0xFF0F172A); // Obsidian Dark
    }
  }

  String get rarityLabel {
    switch (rarity) {
      case RelicRarity.common:
        return 'COMMON PERK';
      case RelicRarity.rare:
        return 'RARE ARTIFACT';
      case RelicRarity.legendary:
        return 'LEGENDARY CODEX';
    }
  }
}

class RelicCatalog {
  RelicCatalog._();

  static const List<LinguisticRelic> allRelics = [
    LinguisticRelic(
      id: 'pocketwatch',
      name: "Synchronizer's Pocketwatch",
      rarity: RelicRarity.rare,
      description: '+35% combat damage when completing linguistic drills under 2.5 seconds.',
      flavorLore: 'Forged in the Royal Phonetics Guild to measure micro-pauses in connected speech.',
      icon: Icons.timer_outlined,
    ),
    LinguisticRelic(
      id: 'connected_speech_prism',
      name: 'Prism of Connected Speech',
      rarity: RelicRarity.legendary,
      description: 'Start every combat turn with 4 Energy instead of 3.',
      flavorLore: 'Refracts sluggish word-by-word speech into fluid phonetic linking.',
      icon: Icons.auto_awesome_rounded,
    ),
    LinguisticRelic(
      id: 'phonetic_aegis',
      name: 'Phonetic Aegis',
      rarity: RelicRarity.common,
      description: 'Gain 8 Block automatically at the beginning of every encounter.',
      flavorLore: 'A crystalline shield forged from precise IPA vowel resonance.',
      icon: Icons.shield_outlined,
    ),
    LinguisticRelic(
      id: 'lexical_codex',
      name: 'Lexical Codex',
      rarity: RelicRarity.rare,
      description: 'Draw 6 cards instead of 5 at the beginning of each turn.',
      flavorLore: 'Expands your working lexical memory for rapid collocation retrieval.',
      icon: Icons.menu_book_rounded,
    ),
    LinguisticRelic(
      id: 'tuning_fork',
      name: 'Acoustic Tuning Fork',
      rarity: RelicRarity.common,
      description: 'Heal +12 HP after completing any Intonation Wave or Minimal Pair trial.',
      flavorLore: 'Resonates at the exact pitch frequency of native RP English vowels.',
      icon: Icons.tune_rounded,
    ),
    LinguisticRelic(
      id: 'idiom_compass',
      name: 'Collocation Compass',
      rarity: RelicRarity.rare,
      description: 'Reward cards after battles have a 50% higher chance to be Rare or Legendary.',
      flavorLore: 'Points unfailingly toward authentic colloquial phrasing rather than textbook stiffness.',
      icon: Icons.explore_outlined,
    ),
    LinguisticRelic(
      id: 'vocal_cord_elixir',
      name: 'Vocal Cord Elixir',
      rarity: RelicRarity.common,
      description: 'Permanently increases maximum expedition stamina (+8 Max HP).',
      flavorLore: 'Brewed from mountain honey and peppermint to soothe vocal tension.',
      icon: Icons.water_drop_outlined,
    ),
    LinguisticRelic(
      id: 'scholars_monocle',
      name: "Scholar's Monocle",
      rarity: RelicRarity.legendary,
      description: 'Reveals the exact grammatical weakness and upcoming intent of all monsters.',
      flavorLore: 'Enables real-time syntactic parsing of complex hostile arguments.',
      icon: Icons.visibility_outlined,
    ),
  ];

  static List<LinguisticRelic> getRandomDraft({int count = 3, List<String> excludeIds = const []}) {
    final available = allRelics.where((r) => !excludeIds.contains(r.id)).toList()..shuffle();
    return available.take(count).toList();
  }
}

