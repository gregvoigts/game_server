import 'dart:math';
import 'dart:typed_data';

import 'entity.dart';

class Monster extends Entity {
  Monster(int id, Point<int> pos) : super(id, pos, EntityType.monster) {
    health = maxHealth = Random().nextInt(101) + 50;
    ap = Random().nextInt(21) + 5;
  }

  Monster.deserilaized(
      int id, Point<int> pos, int health, int ap, int maxHealth)
      : super.deserialized(id, pos, EntityType.monster, health, ap, maxHealth);
}
