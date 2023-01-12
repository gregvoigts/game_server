import 'dart:math';
import 'dart:typed_data';

import 'entity.dart';

class Monster extends Entity {
  Monster(Point<int> pos) : super(pos, EntityType.monster) {
    health = maxHealth = Random().nextInt(101) + 50;
    ap = Random().nextInt(21) + 5;
  }

  Monster.deserilaized(Point<int> pos, int health, int ap, int maxHealth)
      : super.deserilaized(pos, EntityType.monster, health, ap, maxHealth);

  @override
  List<int> serialize() {
    var list = super.serialize();
    list.add(0);
    return list;
  }
}
