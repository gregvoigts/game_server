import 'dart:math';

abstract class Entity {
  late int health;
  late int maxHealth;
  late int ap;
  EntityType type;
  Point<int> pos;

  Entity(this.pos, this.type);

  /// attack this entity with the given power
  /// Returns true if entity is dead
  bool striked(int strength) {
    health -= strength;
    if (health <= 0) {
      health = 0;
      return true;
    }
    return false;
  }
}

enum EntityType { monster, player }
