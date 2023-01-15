import 'dart:math';
import 'dart:typed_data';

import 'package:shared_models/shared_models.dart';
import 'package:shared_models/src/monster.dart';
import 'package:shared_models/src/player.dart';

import 'entity.dart';
import 'util.dart';

class GameState {
  static const int size = 25;
  static const int fields = size * size;

  static const attackRange = 2;
  static const healRange = 5;
  static const moveRange = 1;

  var field = List.generate(size, (index) => List<Entity?>.filled(size, null),
      growable: false);
  int playerCount = 0;
  int monsterCount = 0;
  bool gameRunning = true;

  List<int> serialize() {
    var list = List<int>.empty(growable: true);
    list.addAll([playerCount, monsterCount, gameRunning ? 1 : 0]);
    for (var yPos = 0; yPos < size; yPos++) {
      for (var xPos = 0; xPos < size; xPos++) {
        if (field[yPos][xPos] != null) {
          list.addAll([yPos, xPos]);
          list.addAll(field[yPos][xPos]!.serialize());
        }
      }
    }
    return list;
  }

  GameState();

  GameState._private(this.playerCount, this.monsterCount, this.gameRunning);

  factory GameState.deserialize(Uint8List data) {
    var gameState = GameState._private(data[0], data[1], data[2] == 1);
    int index = 3;
    while (index < data.length) {
      gameState.field[data[index]][data[index + 1]] =
          Entity.deserialize(data.sublist(index + 2, index + 9));
      index += 9;
    }
    return gameState;
  }

  bool spawnPlayer() {
    var p = _spawnPoint();
    if (p == null) {
      return false;
    }
    var newPlayer = Player(p, playerCount);
    field[p.y][p.x] = newPlayer;
    playerCount += 1;
    return true;
  }

  bool spawnMonster() {
    var p = _spawnPoint();
    if (p == null) {
      return false;
    }
    var newMonster = Monster(p);
    field[p.y][p.x] = newMonster;
    monsterCount += 1;
    return true;
  }

  Point<int>? _spawnPoint() {
    if (playerCount + monsterCount >= fields) return null;

    int spawnPoint = Random().nextInt(fields - playerCount - monsterCount);
    for (var yPos = 0; yPos < size; yPos++) {
      for (var xPos = 0; xPos < size; xPos++) {
        if (field[yPos][xPos] != null) {
          continue;
        }
        if (spawnPoint == 0) return Point(xPos, yPos);
        --spawnPoint;
      }
    }
    assert(false, "Never reached");
    return null;
  }

  bool attack(Entity attacker, Entity attacked) {
    var dist = Util.calcDistance(attacker.pos, attacked.pos);
    if (dist > attackRange) {
      return false;
    }

    if (attacked.striked(attacker.ap)) {
      // dead
      field[attacked.pos.y][attacked.pos.x] = null;
      switch (attacked.type) {
        case EntityType.monster:
          monsterCount--;
          break;
        case EntityType.player:
          playerCount--;
          break;
      }
      if (playerCount == 0 || monsterCount == 0) {
        gameRunning = false;
      }
    }
    return true;
  }

  bool heal(Player healer, Player healed) {
    var dist = Util.calcDistance(healer.pos, healed.pos);
    if (dist > healRange) {
      return false;
    }
    healed.heal(healer.ap);
    return true;
  }

  bool move(Player player, int xPos, int yPos) {
    var newPos = Point(xPos, yPos);
    var dist = Util.calcDistance(player.pos, newPos);
    if (dist > moveRange) {
      return false;
    }
    field[player.pos.y][player.pos.x] = null;
    player.pos = newPos;
    field[newPos.y][newPos.x] = player;
    return true;
  }
}
