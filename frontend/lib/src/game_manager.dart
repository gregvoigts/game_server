import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import 'package:frontend/src/network.dart';
import 'package:frontend/src/observe.dart';
import 'package:shared_models/shared_models.dart';

class GameManager extends Observable {
  GameState? _state;
  Network? network;
  int? playerId;

  void init() async {
    network = Network(
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, 25568), this);
    network!.connectToServer();
  }

  GameState? get state => _state;

  void handleDataUpdates(Uint8List data) async {
    _state = GameState.deserialize(data);
    print(_state);
    notify();
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
