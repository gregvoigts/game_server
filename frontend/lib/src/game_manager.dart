import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import 'package:frontend/src/network.dart';
import 'package:shared_models/shared_models.dart';

class GameManager {
  GameState? state;
  Network? network;
  int? playerId;

  void init() async {
    network = Network(
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, 25568), this);
    network!.connectToServer();
  }

  void handleDataUpdates(Uint8List data) async {
    state = GameState.deserialize(data);
    print(state);
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
            if (entity.playerId == playerId) {
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
    var action = Move(player.pos + Util.getVector(dir));
    network!.sendAction(action);
  }

  void heal(Point<int> playerToHeal) {
    if (network == null) {
      return;
    }
    var action = Heal(playerToHeal);
    network!.sendAction(action);
  }

  void attack(Point<int> entityToAttack) {
    if (network == null) {
      return;
    }
    var action = Attack(entityToAttack);
    network!.sendAction(action);
  }
}
