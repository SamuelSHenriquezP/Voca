enum NodeState {
  completed,
  active,
  locked,
  boss,
}

enum LevelFocusType {
  storyReading,   // 📖 Historia y Lectura con Huecos
  syntaxBattle,   // ⚔️ Batalla de Sintaxis
  listeningLab,   // 🎧 Laboratorio de Audio
  scienceExplore, // 🔬 Ciencia y Curiosidades
  dialogueBoss,   // 👑 Jefe de Diálogo
}

class LevelNodeModel {
  final String id;
  final String title;
  final String subtitle;
  final int unitNumber;
  final int levelNumber;
  final NodeState state;
  final LevelFocusType focusType;
  final int stars;
  final int xpReward;
  final List<String> objectives;
  final double xOffset; // Staggered position -1.0 (left), 0.0 (center), 1.0 (right)

  const LevelNodeModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.unitNumber,
    required this.levelNumber,
    required this.state,
    this.focusType = LevelFocusType.syntaxBattle,
    this.stars = 0,
    this.xpReward = 10,
    this.objectives = const [],
    this.xOffset = 0.0,
  });

  String get focusLabel {
    switch (focusType) {
      case LevelFocusType.storyReading:
        return 'HISTORIA';
      case LevelFocusType.syntaxBattle:
        return 'SINTAXIS';
      case LevelFocusType.listeningLab:
        return 'AUDIO LAB';
      case LevelFocusType.scienceExplore:
        return 'CIENCIA';
      case LevelFocusType.dialogueBoss:
        return 'JEFE FINAL';
    }
  }

  String get focusEmoji {
    switch (focusType) {
      case LevelFocusType.storyReading:
        return '📖';
      case LevelFocusType.syntaxBattle:
        return '⚔️';
      case LevelFocusType.listeningLab:
        return '🎧';
      case LevelFocusType.scienceExplore:
        return '🔬';
      case LevelFocusType.dialogueBoss:
        return '👑';
    }
  }
}

