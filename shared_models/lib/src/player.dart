import 'dart:math';
import 'dart:typed_data';
import 'entity.dart';

class Player extends Entity {
  Player(
    int playerId,
    Point<int> pos,
  ) : super(playerId, pos, EntityType.player) {
    health = maxHealth = Random().nextInt(21) + 10;
    ap = Random().nextInt(11) + 1;
  }

  Player.deserilaized(
      int playerId, Point<int> pos, int health, int ap, int maxHealth)
      : super.deserialized(
            playerId, pos, EntityType.player, health, ap, maxHealth);

  void heal(int power) {
    health += power;
    if (health >= maxHealth) health = maxHealth;
  }
}
