import 'dart:math';
import 'dart:typed_data';

import 'entity.dart';

/// Class for a Monster
class Monster extends Entity {
  Monster(int id, Point<int> pos) : super(id, pos, EntityType.monster) {
    health = maxHealth = Random().nextInt(101) + 50;
    ap = Random().nextInt(21) + 5;
  }

  /// Constructor for deserialized Monster
  Monster.deserilaized(
      int id, Point<int> pos, int health, int ap, int maxHealth)
      : super.deserialized(id, pos, EntityType.monster, health, ap, maxHealth);
}
