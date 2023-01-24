import 'dart:math';
import 'dart:typed_data';
import 'entity.dart';

/// Class for a Player
class Player extends Entity {
  Player(
    int playerId,
    Point<int> pos,
  ) : super(playerId, pos, EntityType.player) {
    // Calculate Random health and ap
    health = maxHealth = Random().nextInt(11) + 10;
    ap = Random().nextInt(10) + 1;
  }

  Player.deserilaized(
      int playerId, Point<int> pos, int health, int ap, int maxHealth)
      : super.deserialized(
            playerId, pos, EntityType.player, health, ap, maxHealth);

  /// methode to heal player
  /// if heal is greate than maxHealth.
  /// Set to maxHealth
  void heal(int power) {
    health += power;
    if (health >= maxHealth) health = maxHealth;
  }
}
