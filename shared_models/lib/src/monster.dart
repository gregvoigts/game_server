import 'dart:math';

import 'entity.dart';

class Monster extends Entity {
  Monster(Point<int> pos) : super(pos, EntityType.monster) {
    health = maxHealth = Random().nextInt(101) + 50;
    ap = Random().nextInt(21) + 5;
  }
}
