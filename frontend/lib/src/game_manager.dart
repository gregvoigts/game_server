import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import 'package:frontend/src/network.dart';
import 'package:frontend/src/observe.dart';
import 'package:shared_models/shared_models.dart';

class GameManager extends Observable {
  GameState? _state;
  Network? network;
  int? _playerId;

  void init() async {
    network =
        Network(await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0), this);
    network!.connectToServer();
  }

  GameState? get state => _state;

  set playerId(int value) {
    _playerId = value;
    notify();
  }

  void handleDataUpdates(Uint8List data) async {
    _state = GameState.deserialize(data);
    print(_state);
    notify();
  }

  bool isMe(int playerId) {
    return _playerId == playerId;
  }

  Player? _getOwn() {
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

  void move(Direction dir) {
    if (network == null) {
      return;
    }
    var player = _getOwn();
    if (player == null) {
      return;
    }
    var action = Move(player.pos + Util.getVector(dir), _playerId ?? -1);
    network!.sendAction(action);
  }

  void heal(Point<int> playerToHeal) {
    if (network == null) {
      return;
    }
    var action = Heal(playerToHeal, _playerId ?? -1);
    network!.sendAction(action);
  }

  void attack(Point<int> entityToAttack) {
    if (network == null) {
      return;
    }
    var action = Attack(entityToAttack, _playerId ?? -1);
    network!.sendAction(action);
  }
}
