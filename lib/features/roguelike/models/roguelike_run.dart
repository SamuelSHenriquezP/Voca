import 'package:flutter/material.dart';

enum PerkRarity { common, rare, legendary }

class RoguelikePerk {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final PerkRarity rarity;
  final Color accentColor;

  const RoguelikePerk({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.accentColor,
  });

  static List<RoguelikePerk> get availablePerks => const [
        RoguelikePerk(
          id: 'perk_shield',
          name: 'Shield of Eloquence',
          description: 'Absorbs 1 grammatical blunder per floor without losing a heart.',
          icon: Icons.shield_rounded,
          rarity: PerkRarity.rare,
          accentColor: Color(0xFF0284C7),
        ),
        RoguelikePerk(
          id: 'perk_caffeine',
          name: 'Double Espresso',
          description: 'Adds +4 bonus seconds to all voice recording countdowns.',
          icon: Icons.coffee_rounded,
          rarity: PerkRarity.common,
          accentColor: Color(0xFFD97706),
        ),
        RoguelikePerk(
          id: 'perk_ipa_lens',
          name: 'IPA Acoustic Lens',
          description: 'Reveals syllable stress and phonetic IPA guide during all encounters.',
          icon: Icons.search_rounded,
          rarity: PerkRarity.common,
          accentColor: Color(0xFF4F46E5),
        ),
        RoguelikePerk(
          id: 'perk_streak_inferno',
          name: 'Streak Inferno',
          description: 'Multiplies XP score by 2x when maintaining a combo of 3+ without pauses.',
          icon: Icons.local_fire_department_rounded,
          rarity: PerkRarity.legendary,
          accentColor: Color(0xFFE11D48),
        ),
        RoguelikePerk(
          id: 'perk_second_wind',
          name: 'Second Wind',
          description: 'Immediately restores 2 hearts upon entering Floor 3.',
          icon: Icons.favorite_rounded,
          rarity: PerkRarity.rare,
          accentColor: Color(0xFF059669),
        ),
      ];
}

enum RoomType { combatDrill, minimalPairDuel, intonationWave, speedBlitz, bossBattle, campfireRest }

class RoguelikeRoom {
  final String id;
  final String title;
  final RoomType type;
  final String description;
  final int xpReward;

  const RoguelikeRoom({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.xpReward,
  });
}

class RoguelikeRunState {
  int currentFloor;
  int currentRoomIndex;
  int lives;
  int maxLives;
  int score;
  int combo;
  double difficultyMultiplier;
  List<RoguelikePerk> activePerks;

  RoguelikeRunState({
    this.currentFloor = 1,
    this.currentRoomIndex = 0,
    this.lives = 5,
    this.maxLives = 5,
    this.score = 0,
    this.combo = 0,
    this.difficultyMultiplier = 1.0,
    List<RoguelikePerk>? activePerks,
  }) : activePerks = activePerks ?? [];

  bool get isDead => lives <= 0;

  void takeDamage() {
    // Check if shield perk is active
    final shieldIndex = activePerks.indexWhere((p) => p.id == 'perk_shield');
    if (shieldIndex != -1) {
      activePerks.removeAt(shieldIndex); // Shield consumes itself
      return;
    }
    lives = (lives - 1).clamp(0, maxLives);
    combo = 0;
  }

  void addScore(int baseScore) {
    combo++;
    final comboMult = combo > 2 ? (1.0 + (combo * 0.2)) : 1.0;
    final infernoMult = activePerks.any((p) => p.id == 'perk_streak_inferno') ? 1.5 : 1.0;
    score += (baseScore * difficultyMultiplier * comboMult * infernoMult).toInt();
  }

  void heal(int amount) {
    lives = (lives + amount).clamp(0, maxLives);
  }

  void advanceFloor() {
    currentFloor++;
    currentRoomIndex = 0;
    difficultyMultiplier += 0.35; // Roguelike scaling!
  }
}
