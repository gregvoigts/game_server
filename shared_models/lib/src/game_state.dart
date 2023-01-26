import 'dart:math';
import 'dart:typed_data';
import 'package:shared_models/shared_models.dart';

/// Represents a gamestate.
class GameState {
  /// Game grid size.
  static const int size = 25;

  /// Number of all fields.
  static const int fields = size * size;

  /// Attack range for all entities.
  static const attackRange = 2;

  /// Heal range for players.
  static const healRange = 5;

  /// Move range for players.
  static const moveRange = 1;

  /// Holds the whole game area.
  var field = List.generate(size, (index) => List<Entity?>.filled(size, null),
      growable: false);

  /// Counts the remaining player.
  int playerCount = 0;

  /// Counts the remaining monster.
  int monsterCount = 0;

  /// Whether the game is still/already running.
  bool gameRunning = true;

  /// id of the clients Aktion
  int actionId = 0;

  /// id of the player executed the action
  int playerId = 0;

  /// statistics of the actions
  Map<String, int> actionCounts = {
    'moves': 0,
    'heals': 0,
    'player_attacks': 0,
    'monster_attacks': 0,
  };

  GameState();

  GameState._private(this.playerCount, this.monsterCount, this.gameRunning,
      this.actionId, this.playerId);

  /// Serialize GameState
  /// First add all int Values of the State
  /// Then add a Part for ever Entity
  /// The first to indezies are for the Position of the Entity in the Grid
  /// Then add the ByteList for a serialized Entity
  List<int> serialize() {
    var list = List<int>.empty(growable: true);
    list.addAll(
        [playerCount, monsterCount, gameRunning ? 1 : 0, actionId, playerId]);
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

  /// Creates GameState back from serialized Data
  /// Every entity is exactly 9 Bytes
  /// 7 Bytes for the Entity 2 Bytes for the Position
  factory GameState.deserialize(Uint8List data) {
    var gameState =
        GameState._private(data[0], data[1], data[2] == 1, data[3], data[4]);
    int index = 5;
    while (index < data.length) {
      gameState.field[data[index]][data[index + 1]] =
          Entity.deserialize(data.sublist(index + 2, index + 9));
      index += 9;
    }
    return gameState;
  }

  /// Checks if a given points is in the bounds of the game area.
  bool isValidPosition(Point<int> position) => !(position.x >= size ||
      position.y >= size ||
      position.x < 0 ||
      position.y < 0);

  /// Returns the entity at a given coordiante or null if the position is empty.
  ///
  /// Invalid position leads to error.
  Entity? getField(Point<int> position) {
    if (!isValidPosition(position)) assert(false, 'Invalid field-position!');
    return field[position.y][position.x];
  }

  /// Spawns a player on a random free position on the board.
  ///
  /// Returns true if a player has been spawned.
  Player? spawnPlayer(int id) {
    var p = _spawnPoint();
    if (p == null) {
      return null;
    }
    var newPlayer = Player(id, p);
    field[p.y][p.x] = newPlayer;
    playerCount += 1;
    return newPlayer;
  }

  /// Spawns a monster on a random free position on the board.
  ///
  /// Returns true if a monster has been spawned.
  bool spawnMonster(int id) {
    var p = _spawnPoint();
    if (p == null) {
      return false;
    }
    var newMonster = Monster(id, p);
    field[p.y][p.x] = newMonster;
    monsterCount += 1;
    return true;
  }

  /// Returns a random free position on the board.
  ///
  /// Returns null if no more positions are free.
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

  /// find the first occurence of entityId on the field
  ///
  /// Returns null if the entity can't be found
  Entity? find(int entityId) {
    for (var row in field) {
      for (var cell in row) {
        if (cell != null && cell.playerId == entityId) {
          return cell;
        }
      }
    }
    return null;
  }

  /// Executes an attack from attacker to attacked.
  ///
  /// Updates monster/player count if the attacked died.
  /// Does not check if an attack is allowed!
  void attack(int damage, Entity attacked) {
    if (attacked.striked(damage)) {
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
    var key = attacked.type == EntityType.monster
        ? 'player_attacks'
        : 'monster_attacks';
    actionCounts[key] = actionCounts[key]! + 1;
  }

  /// Returns true an attack from attacker against attacked is allowed.
  bool canAttack(Entity attacker, Entity attacked) {
    var dist = Util.calcDistance(attacker.pos, attacked.pos);
    if (dist > attackRange) return false;

    return true;
  }

  /// Executes an heal from healer to healed.
  ///
  /// Does not check if a heal is allowed!
  void heal(int power, Player healed) {
    healed.heal(power);
    actionCounts['heals'] = actionCounts['heals']! + 1;
  }

  /// Returns true if healer can heal healed.
  bool canHeal(Player healer, Player healed) {
    var dist = Util.calcDistance(healer.pos, healed.pos);
    if (dist > healRange) return false;

    return true;
  }

  /// Moves the player to a given position.
  ///
  /// Does not check if a move is allowed!
  void move(Player player, Point<int> newPos) {
    field[player.pos.y][player.pos.x] = null;
    player.pos = newPos;
    field[newPos.y][newPos.x] = player;
    actionCounts['moves'] = actionCounts['moves']! + 1;
  }

  /// Returns true if a move of player to newPos is allowed.
  bool canMove(Player player, Point<int> newPos, {bool overrideRange = false}) {
    var dist = Util.calcDistance(player.pos, newPos);
    if ((!overrideRange && dist > moveRange) ||
        (field[newPos.y][newPos.x] != null &&
            field[newPos.y][newPos.x] != player)) return false;

    return true;
  }
}
