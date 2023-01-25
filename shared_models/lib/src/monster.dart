import 'dart:math';
import 'dart:typed_data';

import 'entity.dart';

/// Class for a Monster
class Monster extends Entity {
  /// The monster should attack after every ~X received attacks
  final int maxAttackCooldown = 3;
  int attackCooldown = 3;

  Monster(int id, Point<int> pos) : super(id, pos, EntityType.monster) {
    health = maxHealth = Random().nextInt(51) + 50;
    ap = Random().nextInt(16) + 5;
  }

  /// Constructor for deserialized Monster
  Monster.deserilaized(
      int id, Point<int> pos, int health, int ap, int maxHealth)
      : super.deserialized(id, pos, EntityType.monster, health, ap, maxHealth);
}
