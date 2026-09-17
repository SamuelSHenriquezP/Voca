import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';

enum TacticalCardType {
  shield,
  clue,
  skip,
  doubleXp,
}

class TacticalCard {
  final TacticalCardType type;
  final String title;
  final String shortName;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color lightBg;
  final Color borderColor;
  final String badge;

  const TacticalCard({
    required this.type,
    required this.title,
    required this.shortName,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.lightBg,
    required this.borderColor,
    required this.badge,
  });

  static const TacticalCard shieldCard = TacticalCard(
    type: TacticalCardType.shield,
    title: 'Escudo Anti-Error',
    shortName: 'Escudo',
    description: 'Absorbe un error sin perder corazones ni romper racha.',
    icon: Icons.shield_rounded,
    primaryColor: Color(0xFF0D9488), // Clean teal/emerald
    lightBg: Color(0xFFF0FDFA),
    borderColor: Color(0xFF99F6E4),
    badge: 'DEFENSA',
  );

  static const TacticalCard clueCard = TacticalCard(
    type: TacticalCardType.clue,
    title: 'Pista 50/50',
    shortName: 'Pista 50/50',
    description: 'Descarta opciones incorrectas o coloca la siguiente palabra.',
    icon: Icons.lightbulb_rounded,
    primaryColor: Color(0xFFD97706), // Warm amber
    lightBg: Color(0xFFFFFBEB),
    borderColor: Color(0xFFFDE68A),
    badge: 'SOPORTE',
  );

  static const TacticalCard skipCard = TacticalCard(
    type: TacticalCardType.skip,
    title: 'Salto Estratégico',
    shortName: 'Saltar',
    description: 'Supera la pregunta actual al instante sin penalización.',
    icon: Icons.fast_forward_rounded,
    primaryColor: Color(0xFF4F46E5), // Indigo
    lightBg: Color(0xFFEEF2FF),
    borderColor: Color(0xFFC7D2FE),
    badge: 'UTILIDAD',
  );

  static const TacticalCard doubleXpCard = TacticalCard(
    type: TacticalCardType.doubleXp,
    title: 'Impulso 2x XP',
    shortName: '2x XP',
    description: 'Duplica toda la experiencia (XP) ganada al completar la lección.',
    icon: Icons.bolt_rounded,
    primaryColor: Color(0xFFEA580C), // Orange
    lightBg: Color(0xFFFFF7ED),
    borderColor: Color(0xFFFED7AA),
    badge: 'BOOST',
  );

  static const List<TacticalCard> all = [
    shieldCard,
    clueCard,
    skipCard,
    doubleXpCard,
  ];

  static int getCount(TacticalCardType type) {
    final storage = LocalStorageService();
    switch (type) {
      case TacticalCardType.shield:
        return storage.getShields();
      case TacticalCardType.clue:
        return storage.getClues();
      case TacticalCardType.skip:
        return storage.getSkips();
      case TacticalCardType.doubleXp:
        return storage.getDoubleXpCount();
    }
  }

  static bool use(TacticalCardType type) {
    final storage = LocalStorageService();
    switch (type) {
      case TacticalCardType.shield:
        return storage.useShield();
      case TacticalCardType.clue:
        return storage.useClue();
      case TacticalCardType.skip:
        return storage.useSkip();
      case TacticalCardType.doubleXp:
        return storage.useDoubleXp();
    }
  }

  static void add(TacticalCardType type, int count) {
    final storage = LocalStorageService();
    switch (type) {
      case TacticalCardType.shield:
        storage.addShield(count);
        break;
      case TacticalCardType.clue:
        storage.addClue(count);
        break;
      case TacticalCardType.skip:
        storage.addSkip(count);
        break;
      case TacticalCardType.doubleXp:
        storage.addDoubleXp(count);
        break;
    }
  }
}
