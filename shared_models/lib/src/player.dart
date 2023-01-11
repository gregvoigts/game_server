import 'dart:math';
import 'entity.dart';

class Player extends Entity {
  Player(Point<int> pos) : super(pos, EntityType.player) {
    health = maxHealth = Random().nextInt(21) + 10;
    ap = Random().nextInt(11) + 1;
  }

  void heal(int power) {
    health += power;
    if (health >= maxHealth) health = maxHealth;
  }
}
