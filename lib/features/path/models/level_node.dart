enum NodeState {
  completed,
  active,
  locked,
  boss,
}

class LevelNodeModel {
  final String id;
  final String title;
  final String subtitle;
  final int unitNumber;
  final int levelNumber;
  final NodeState state;
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
    this.stars = 0,
    this.xpReward = 10,
    this.objectives = const [],
    this.xOffset = 0.0,
  });
}

