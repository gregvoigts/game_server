import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:shared_models/shared_models.dart';

abstract class SyncAction {
  SyncType type;

  SyncAction(this.type);

  List<int> serialize() {
    return [type.index];
  }

  factory SyncAction.deserialize(Uint8List data) {
    switch (SyncType.values[data[0]]) {
      case SyncType.hurt:
        return ServerHurt(data[1], data[2]);
      case SyncType.move:
        return ServerMove(data[1], Point(data[2], data[3]));
      case SyncType.heal:
        return ServerHeal(data[1], data[2]);
      case SyncType.gameState:
        return SendGamestate(GameState.deserialize(data.sublist(1)));
      case SyncType.newClient:
        return NewClient.deserialize(
            Entity.deserialize(data.sublist(1)) as Player, data.sublist(8));
      case SyncType.askGameState:
        return AskGameState();
    }
  }
}

abstract class GameActionSync extends SyncAction {
  int entityId;

  GameActionSync(this.entityId, SyncType type) : super(type);
}

class SendGamestate extends SyncAction {
  GameState state;

  SendGamestate(this.state) : super(SyncType.gameState);

  @override
  List<int> serialize() {
    return [...super.serialize(), ...state.serialize()];
  }
}

class AskGameState extends SyncAction {
  AskGameState() : super(SyncType.askGameState);
}

class ServerMove extends GameActionSync {
  Point<int> dest;

  ServerMove(int entityId, this.dest) : super(entityId, SyncType.move);

  @override
  List<int> serialize() {
    return [...super.serialize(), entityId, dest.x, dest.y];
  }
}

class ServerHurt extends GameActionSync {
  int damage;

  ServerHurt(int entityId, this.damage) : super(entityId, SyncType.hurt);

  @override
  List<int> serialize() {
    return [...super.serialize(), entityId, damage];
  }
}

class ServerHeal extends GameActionSync {
  int power;

  ServerHeal(entityId, this.power) : super(entityId, SyncType.heal);

  @override
  List<int> serialize() {
    return [...super.serialize(), entityId, power];
  }
}

class NewClient extends SyncAction {
  int udpPort;
  InternetAddress clientIp;
  Player player;

  NewClient(this.udpPort, this.clientIp, this.player)
      : super(SyncType.newClient);

  factory NewClient.deserialize(Player player, Uint8List data) {
    var connStr = utf8.decode(data);
    var connAr = connStr.split(':');
    return NewClient(int.parse(connAr[1]), InternetAddress(connAr[0]), player);
  }

  @override
  List<int> serialize() {
    return [
      ...super.serialize(),
      ...player.serialize(),
      ...utf8.encode('${clientIp.address}:$udpPort')
    ];
  }
}

enum SyncType { gameState, move, hurt, heal, newClient, askGameState }
