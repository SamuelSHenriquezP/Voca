import 'dart:math' as math;
import 'package:flutter/material.dart';

enum MonsterIntentType { attack, defend, buff, debuff }

class MonsterIntent {
  final MonsterIntentType type;
  final int value;
  final String name;
  final String description;

  const MonsterIntent({
    required this.type,
    required this.value,
    required this.name,
    required this.description,
  });

  IconData get icon {
    switch (type) {
      case MonsterIntentType.attack:
        return Icons.flash_on_rounded;
      case MonsterIntentType.defend:
        return Icons.shield_rounded;
      case MonsterIntentType.buff:
        return Icons.arrow_upward_rounded;
      case MonsterIntentType.debuff:
        return Icons.arrow_downward_rounded;
    }
  }

  Color get color {
    switch (type) {
      case MonsterIntentType.attack:
        return const Color(0xFFE11D48);
      case MonsterIntentType.defend:
        return const Color(0xFF0284C7);
      case MonsterIntentType.buff:
        return const Color(0xFFD97706);
      case MonsterIntentType.debuff:
        return const Color(0xFF7C3AED);
    }
  }
}

class LinguisticMonster {
  final String id;
  final String name;
  final String title;
  final int maxHp;
  int hp;
  int block;
  final String cefrLevel;
  final bool isBoss;
  final bool isElite;
  final String avatarPainterId;
  MonsterIntent currentIntent;

  LinguisticMonster({
    required this.id,
    required this.name,
    required this.title,
    required this.maxHp,
    required this.hp,
    this.block = 0,
    required this.cefrLevel,
    this.isBoss = false,
    this.isElite = false,
    required this.avatarPainterId,
    required this.currentIntent,
  });

  bool get isDead => hp <= 0;

  void takeDamage(int amount) {
    if (block > 0) {
      if (amount <= block) {
        block -= amount;
        return;
      } else {
        final remaining = amount - block;
        block = 0;
        hp = (hp - remaining).clamp(0, maxHp);
        return;
      }
    }
    hp = (hp - amount).clamp(0, maxHp);
  }

  void gainBlock(int amount) {
    block += amount;
  }

  void planNextIntent(int turn) {
    final random = math.Random();
    if (isBoss) {
      if (turn % 3 == 0) {
        currentIntent = MonsterIntent(
          type: MonsterIntentType.attack,
          value: 18 + (turn * 2),
          name: 'Cadence Cataclysm',
          description: 'Devastating acoustic shockwave testing full defensive reserve.',
        );
      } else if (turn % 3 == 1) {
        currentIntent = const MonsterIntent(
          type: MonsterIntentType.defend,
          value: 14,
          name: 'Monotone Barrier',
          description: 'Surrounds itself with dense syntactic armor.',
        );
      } else {
        currentIntent = const MonsterIntent(
          type: MonsterIntentType.attack,
          value: 12,
          name: 'Flat Vowel Slash',
          description: 'A rapid robotic strike targeting speech tempo.',
        );
      }
    } else {
      final roll = random.nextDouble();
      if (roll < 0.6) {
        currentIntent = MonsterIntent(
          type: MonsterIntentType.attack,
          value: 7 + random.nextInt(6),
          name: 'Hesitation Jab',
          description: 'Strikes quickly before you can formulate phrases.',
        );
      } else {
        currentIntent = MonsterIntent(
          type: MonsterIntentType.defend,
          value: 6 + random.nextInt(6),
          name: 'Syntactic Guard',
          description: 'Raises a protective ward against verbal attacks.',
        );
      }
    }
  }

  static LinguisticMonster createEncounter({
    required bool isBoss,
    required bool isElite,
    required int floor,
  }) {
    if (isBoss) {
      return LinguisticMonster(
        id: 'boss_monotone_warden',
        name: 'The Monotone Warden',
        title: 'Guardian of Rigid Syllables',
        maxHp: 90,
        hp: 90,
        cefrLevel: 'A1-A2',
        isBoss: true,
        avatarPainterId: 'monotone_warden',
        currentIntent: const MonsterIntent(
          type: MonsterIntentType.attack,
          value: 12,
          name: 'Robotic Cadence',
          description: 'Strikes with mechanical predictability.',
        ),
      );
    } else if (isElite) {
      return LinguisticMonster(
        id: 'elite_syntax_colossus',
        name: 'The Syntax Colossus',
        title: 'Titan of Run-on Sentences',
        maxHp: 65,
        hp: 65,
        cefrLevel: 'A2',
        isElite: true,
        avatarPainterId: 'redundant_colossus',
        currentIntent: const MonsterIntent(
          type: MonsterIntentType.attack,
          value: 14,
          name: 'Grammar Slam',
          description: 'Crushes with heavy clunky clauses.',
        ),
      );
    } else {
      return LinguisticMonster(
        id: 'mob_glitch_$floor',
        name: 'Acoustic Phantom',
        title: 'Distorted Syllable Entity',
        maxHp: 38 + (floor * 4),
        hp: 38 + (floor * 4),
        cefrLevel: 'A1',
        avatarPainterId: 'syntax_golem',
        currentIntent: const MonsterIntent(
          type: MonsterIntentType.attack,
          value: 8,
          name: 'Phoneme Discord',
          description: 'Scatters sound waves in your direction.',
        ),
      );
    }
  }
}
