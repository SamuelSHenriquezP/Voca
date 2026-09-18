import 'dart:math' as math;
import 'package:flutter/material.dart';

enum MapNodeType {
  battle,
  elite,
  mysteryEvent,
  restShrine,
  merchantShop,
  boss,
  intonationWave,
  minimalPairDuel,
  speedBlitz,
}

class MapNode {
  final String id;
  final int floor;
  final int lane; // 0 (Left), 1 (Center), 2 (Right)
  final MapNodeType type;
  final String title;
  final String subtitle;
  final List<String> connectedNodeIds;
  bool isCompleted;
  bool isAvailable;

  MapNode({
    required this.id,
    required this.floor,
    required this.lane,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.connectedNodeIds,
    this.isCompleted = false,
    this.isAvailable = false,
  });

  IconData get icon {
    switch (type) {
      case MapNodeType.battle:
        return Icons.flash_on_rounded;
      case MapNodeType.elite:
        return Icons.whatshot_rounded;
      case MapNodeType.mysteryEvent:
        return Icons.help_outline_rounded;
      case MapNodeType.restShrine:
        return Icons.nightlight_round;
      case MapNodeType.merchantShop:
        return Icons.storefront_rounded;
      case MapNodeType.boss:
        return Icons.shield_rounded;
      case MapNodeType.intonationWave:
        return Icons.waves_rounded;
      case MapNodeType.minimalPairDuel:
        return Icons.hearing_rounded;
      case MapNodeType.speedBlitz:
        return Icons.timer_rounded;
    }
  }

  Color get color {
    switch (type) {
      case MapNodeType.battle:
        return const Color(0xFF0F172A); // Dark slate
      case MapNodeType.elite:
        return const Color(0xFFD97706); // Amber
      case MapNodeType.mysteryEvent:
        return const Color(0xFF64748B); // Slate neutral
      case MapNodeType.restShrine:
        return const Color(0xFF059669); // Emerald
      case MapNodeType.merchantShop:
        return const Color(0xFF0284C7); // Cyan
      case MapNodeType.boss:
        return const Color(0xFF0F172A); // Midnight boss
      case MapNodeType.intonationWave:
        return const Color(0xFF0284C7); // Cyan intonation
      case MapNodeType.minimalPairDuel:
        return const Color(0xFF059669); // Emerald acoustic
      case MapNodeType.speedBlitz:
        return const Color(0xFFE11D48); // Rose reflex sprint
    }
  }
}

class ProceduralMap {
  final int totalFloors;
  final List<MapNode> allNodes;
  String? currentNodeId;

  ProceduralMap({
    required this.totalFloors,
    required this.allNodes,
    this.currentNodeId,
  });

  List<MapNode> getNodesForFloor(int floor) {
    return allNodes.where((n) => n.floor == floor).toList();
  }

  MapNode? getNodeById(String id) {
    try {
      return allNodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  void visitNode(String nodeId) {
    final node = getNodeById(nodeId);
    if (node == null) return;

    node.isCompleted = true;
    currentNodeId = nodeId;

    // Reset availability for all nodes
    for (final n in allNodes) {
      n.isAvailable = false;
    }

    // Set connected nodes on next floor as available
    for (final targetId in node.connectedNodeIds) {
      final target = getNodeById(targetId);
      if (target != null) {
        target.isAvailable = true;
      }
    }
  }

  static ProceduralMap generateMap({int seed = 42, int floors = 8}) {
    final random = math.Random(seed);
    final List<MapNode> nodes = [];

    // Floor 1: 2-3 Battle nodes
    final floor1Count = 2 + random.nextInt(2); // 2 or 3
    for (int lane = 0; lane < floor1Count; lane++) {
      nodes.add(
        MapNode(
          id: 'node_1_$lane',
          floor: 1,
          lane: floor1Count == 2 ? (lane == 0 ? 0 : 2) : lane,
          type: MapNodeType.battle,
          title: 'Acoustic Ambush',
          subtitle: 'Phonetic skirmish with rogue syllables',
          connectedNodeIds: [],
          isAvailable: true, // Floor 1 nodes are immediately available
        ),
      );
    }

    // Floors 2 to (floors - 2)
    for (int floor = 2; floor <= floors - 2; floor++) {
      final nodeCount = 2 + random.nextInt(2); // 2 or 3 lanes
      final List<int> lanes = nodeCount == 2 ? [0, 2] : [0, 1, 2];

      for (final lane in lanes) {
        // Procedural room selection
        MapNodeType type;
        String title;
        String subtitle;

        if (floor == 4) {
          // Guaranteed rest or event before elite floor
          if (lane == 1 || random.nextBool()) {
            type = MapNodeType.restShrine;
            title = 'Vocal Oasis';
            subtitle = 'Rest and replenish hearts or reinforce cards';
          } else {
            type = MapNodeType.mysteryEvent;
            title = 'Echo Cavern';
            subtitle = 'Encounter ancient language spirits';
          }
        } else if (floor == 5) {
          // Mid-dungeon Elite or Merchant
          if (lane == 1) {
            type = MapNodeType.elite;
            title = 'Syntax Colossus';
            subtitle = 'High difficulty trial with rare card relic rewards';
          } else {
            type = MapNodeType.merchantShop;
            title = "Scholar's Bazaar";
            subtitle = 'Acquire rare idioms and relics';
          }
        } else {
          final roll = random.nextDouble();
          if (roll < 0.28) {
            type = MapNodeType.battle;
            title = 'Linguistic Duel';
            subtitle = 'Combat against grammatical blunders';
          } else if (roll < 0.46) {
            type = MapNodeType.intonationWave;
            title = 'Intonation Wave';
            subtitle = 'Ride native pitch contours with your vocal rhythm';
          } else if (roll < 0.64) {
            type = MapNodeType.minimalPairDuel;
            title = 'Minimal Pair Duel';
            subtitle = 'Acoustic vowel & consonant discrimination under pressure';
          } else if (roll < 0.82) {
            type = MapNodeType.speedBlitz;
            title = 'Speed Blitz 45s';
            subtitle = 'Fast reflex conversational sprint against the clock';
          } else if (roll < 0.92) {
            type = MapNodeType.mysteryEvent;
            title = 'Parchment Shrine';
            subtitle = 'A mystical dilemma of speech and choice';
          } else {
            type = MapNodeType.merchantShop;
            title = 'Lexicon Trader';
            subtitle = 'Exchange fluency credits for deck cards';
          }
        }

        nodes.add(
          MapNode(
            id: 'node_${floor}_$lane',
            floor: floor,
            lane: lane,
            type: type,
            title: title,
            subtitle: subtitle,
            connectedNodeIds: [],
          ),
        );
      }
    }

    // Floor (floors - 1): Pre-Boss Rest Site
    nodes.add(
      MapNode(
        id: 'node_${floors - 1}_1',
        floor: floors - 1,
        lane: 1,
        type: MapNodeType.restShrine,
        title: "Sanctuary of the Voice",
        subtitle: "Final preparation before facing the Guardian",
        connectedNodeIds: [],
      ),
    );

    // Floor floors: Boss Node
    nodes.add(
      MapNode(
        id: 'node_${floors}_1',
        floor: floors,
        lane: 1,
        type: MapNodeType.boss,
        title: 'The Monotone Warden',
        subtitle: 'Climactic CEFR Guardian Encounter',
        connectedNodeIds: [],
      ),
    );

    // Now procedurally wire connections between adjacent floors
    for (int floor = 1; floor < floors; floor++) {
      final currentFloorNodes = nodes.where((n) => n.floor == floor).toList();
      final nextFloorNodes = nodes.where((n) => n.floor == floor + 1).toList();

      for (final current in currentFloorNodes) {
        if (nextFloorNodes.length == 1) {
          // Single destination (e.g. into Sanctuary or Boss)
          current.connectedNodeIds.add(nextFloorNodes.first.id);
        } else {
          // Connect to nodes within +/- 1 lane
          final candidates = nextFloorNodes.where((target) {
            return (target.lane - current.lane).abs() <= 1;
          }).toList();

          if (candidates.isNotEmpty) {
            for (final c in candidates) {
              current.connectedNodeIds.add(c.id);
            }
          } else {
            // Fallback: connect to closest
            nextFloorNodes.sort((a, b) =>
                (a.lane - current.lane).abs().compareTo((b.lane - current.lane).abs()));
            current.connectedNodeIds.add(nextFloorNodes.first.id);
          }
        }
      }

      // Ensure every next floor node has at least one parent
      for (final next in nextFloorNodes) {
        final hasParent = currentFloorNodes
            .any((parent) => parent.connectedNodeIds.contains(next.id));
        if (!hasParent) {
          // Connect closest current node
          currentFloorNodes.sort((a, b) =>
              (a.lane - next.lane).abs().compareTo((b.lane - next.lane).abs()));
          currentFloorNodes.first.connectedNodeIds.add(next.id);
        }
      }
    }

    return ProceduralMap(totalFloors: floors, allNodes: nodes);
  }
}
