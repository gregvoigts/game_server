import 'dart:math';
import 'dart:typed_data';

import 'package:shared_models/shared_models.dart';

/// Abstract Class for all Actions from Client to Server
abstract class Action {
  ActionType type;

  int actionId;

  /// target field of Action
  Point<int> destination;

  ///Player executing the Action
  int playerId;

  Action(this.type, this.destination, this.playerId, {this.actionId = 0});

  /// Serializes all Information of this Action
  Uint8List serialize() {
    return Uint8List.fromList(
        [destination.x, destination.y, playerId, type.index, actionId]);
  }

  /// Deserializes bytes back to Action Object
  /// ActionType identified by 4 byte
  factory Action.deserialize(Uint8List data) {
    switch (ActionType.values[data[3]]) {
      case ActionType.attack:
        return Attack(Point(data[0], data[1]), data[2], actionId: data[3]);
      case ActionType.move:
        return Move(Point(data[0], data[1]), data[2], actionId: data[3]);
      case ActionType.heal:
        return Heal(Point(data[0], data[1]), data[2], actionId: data[3]);
    }
  }
}

class Move extends Action {
  Move(Point<int> dest, int id, {int actionId = 0})
      : super(ActionType.move, dest, id, actionId: actionId);
}

class Heal extends Action {
  Heal(Point<int> dest, int id, {int actionId = 0})
      : super(ActionType.heal, dest, id, actionId: actionId);
}

class Attack extends Action {
  Attack(Point<int> dest, int id, {int actionId = 0})
      : super(ActionType.attack, dest, id, actionId: actionId);
}

enum ActionType { move, attack, heal }
