import 'dart:math';
import 'dart:typed_data';

import 'package:shared_models/src/monster.dart';
import 'package:shared_models/src/player.dart';

abstract class Entity {
  late int health;
  late int maxHealth;
  late int ap;
  EntityType type;
  Point<int> pos;

  Entity(this.pos, this.type);

  Entity.deserialized(
      this.pos, this.type, this.health, this.ap, this.maxHealth);

  /// Attacks this entity with the given power.
  ///
  /// Returns true if entity is dead.
  bool striked(int strength) {
    health -= strength;
    if (health <= 0) {
      health = 0;
      return true;
    }
    return false;
  }

  List<int> serialize() {
    return [type.index, health, ap, maxHealth, pos.x, pos.y];
  }

  factory Entity.deserialize(Uint8List data) {
    switch (EntityType.values[data[0]]) {
      case EntityType.player:
        return Player.deserilaized(
            data[6], Point(data[4], data[5]), data[1], data[2], data[3]);
      case EntityType.monster:
        return Monster.deserilaized(
            Point(data[4], data[5]), data[1], data[2], data[3]);
    }
  }
}

enum EntityType { monster, player }
