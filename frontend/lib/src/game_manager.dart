import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import 'package:frontend/src/network.dart';
import 'package:frontend/src/observe.dart';
import 'package:shared_models/shared_models.dart';

/// Class with all Parts of the Game
class GameManager extends Observable {
  ///Current State
  GameState? _state;

  /// Network class to communicate with Server
  Network? network;

  /// Player id of this Client
  int? _playerId;

  void Function(Map<dynamic, dynamic> results)? onFinish;

  /// Initialize the Network component
  void init() async {
    network = Network(
        await RawDatagramSocket.bind(InternetAddress("127.0.0.1"), 0), this);
    network!.connectToServer();
  }

  GameState? get state => _state;

  set playerId(int? value) {
    _playerId = value;
    notify();
  }

  int? get playerId => _playerId;

  /// handels Gamestates recieved from Server
  /// Sends update to UI
  void handleDataUpdates(GameState data) async {
    _state = data;
    notify();
  }

  Map<String, Object> getStatistics() {
    var rtts = <int>[];
    var noResp = 0;
    for (var respTime in network!.responseTimes) {
      if (respTime.recieveTime == null) {
        noResp++;
      } else {
        rtts.add(respTime.recieveTime! - respTime.sendTime);
      }
    }
    var results = {
      "RTTs": rtts,
      "actionsSend": network!.actions,
      "noResp": noResp
    };
    return results;
  }

  bool isMe(int playerId) {
    return _playerId == playerId;
  }

  /// Search the GameField for the Entity with the Clients Id
  Player? getOwn() {
    if (state == null) {
      return null;
    }
    for (var yPos = 0; yPos < GameState.size; yPos++) {
      for (var xPos = 0; xPos < GameState.size; xPos++) {
        if (state!.field[yPos][xPos] != null) {
          var entity = state!.field[yPos][xPos]!;
          if (entity.runtimeType == Player) {
            entity as Player;
            if (entity.playerId == _playerId) {
              return entity;
            }
          }
        }
      }
    }
    return null;
  }

  /// Search in circles arround Player for other Entitys of type T
  T? getFirstInRange<T extends Entity>(Point<int> center, int range) {
    if (_state == null) {
      return null;
    }
    // Start with radius 1 and increment
    int maxRadius = range >= 0 ? range : 1;
    for (int r = 1; r <= maxRadius; r++) {
      // search the hole field
      if (range < 0) maxRadius++;
      var foundValidField = false;
      // Search for +r to -r
      for (int x = r; x >= -r; x--) {
        // y is the radius - x
        var v = center + Point<int>(x, r - x.abs());
        if (_state!.isValidPosition(v)) {
          foundValidField = true;
          if (_state!.field[v.y][v.x].runtimeType == T) {
            return _state!.field[v.y][v.x] as T;
          }
        }
        // search at negation of y if y != 0
        if (v.y == 0) continue;
        var v1 = center + Point(x, (r - x.abs()) * -1);
        if (!_state!.isValidPosition(v1)) continue;
        foundValidField = true;
        if (_state!.field[v1.y][v1.x].runtimeType == T) {
          return _state!.field[v1.y][v1.x] as T;
        }
      }
      //end search if there wasn't found a single valid field in range
      if (!foundValidField) return null;
    }
    return null;
  }

  /// Prepares Action for a Move of the Player and sends to Server
  void move(Direction dir) {
    if (network == null) {
      return;
    }
    var player = getOwn();
    if (player == null) {
      return;
    }
    var action = Move(player.pos + Util.getVector(dir), _playerId ?? -1);
    network!.sendAction(action);
  }

  void moveTo(Point<int> vec) {
    if (network == null) {
      return;
    }
    var player = getOwn();
    if (player == null) {
      return;
    }
    var action = Move(player.pos + vec, _playerId ?? -1);
    network!.sendAction(action);
  }

  /// Prepares Action for a Heal from Clients player to another and sends to Server
  void heal(Point<int> playerToHeal) {
    if (network == null) {
      return;
    }
    var action = Heal(playerToHeal, _playerId ?? -1);
    network!.sendAction(action);
  }

  /// Prepares Action for a Attack from Clients player to another and sends to Server
  void attack(Point<int> entityToAttack) {
    if (network == null) {
      return;
    }
    var action = Attack(entityToAttack, _playerId ?? -1);
    network!.sendAction(action);
  }
}
