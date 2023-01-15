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

  void move(Direction dir) {
    if (network == null) {
      return;
    }

    var action = Move(Point(0, 0));
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

enum Direction { left, right, up, down }
