import 'dart:math';
import 'dart:typed_data';
import 'entity.dart';

class Player extends Entity {
  int playerId;
  Player(Point<int> pos, this.playerId) : super(pos, EntityType.player) {
    health = maxHealth = Random().nextInt(21) + 10;
    ap = Random().nextInt(11) + 1;
  }

  Player.deserilaized(
      this.playerId, Point<int> pos, int health, int ap, int maxHealth)
      : super.deserilaized(pos, EntityType.player, health, ap, maxHealth);

  void heal(int power) {
    health += power;
    if (health >= maxHealth) health = maxHealth;
  }

  @override
  List<int> serialize() {
    var list = super.serialize();
    list.add(playerId);
    return list;
  }
}
