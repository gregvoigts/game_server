import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:shared_models/src/monster.dart';
import 'package:shared_models/src/player.dart';

/// Parent class for all Entities
abstract class Entity {
  /// Id of the Entity
  int playerId;
  late int health;
  late int maxHealth;
  late int ap;
  EntityType type;

  /// Position on the game field
  Point<int> pos;

  Entity(this.playerId, this.pos, this.type);

  /// Constructor vor a deserialized Entity
  Entity.deserialized(
      this.playerId, this.pos, this.type, this.health, this.ap, this.maxHealth);

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

  /// Serialized all Data from the Entity
  List<int> serialize() {
    return [type.index, health, ap, maxHealth, pos.x, pos.y, playerId];
  }

  /// Creates Entity from Serialized Bytedata
  factory Entity.deserialize(Uint8List data) {
    switch (EntityType.values[data[0]]) {
      case EntityType.player:
        return Player.deserilaized(
            data[6], Point(data[4], data[5]), data[1], data[2], data[3]);
      case EntityType.monster:
        return Monster.deserilaized(
            data[6], Point(data[4], data[5]), data[1], data[2], data[3]);
    }
  }
}

enum EntityType { monster, player }
