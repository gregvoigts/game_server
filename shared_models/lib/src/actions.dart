import 'dart:math';
import 'dart:typed_data';

import 'package:shared_models/shared_models.dart';

/// Abstract Class for all Actions from Client to Server
abstract class Action {
  ActionType type;

  /// target field of Action
  Point<int> destination;

  ///Player executing the Action
  int playerId;

  Action(this.type, this.destination, this.playerId);

  /// Serializes all Information of this Action
  Uint8List serialize() {
    return Uint8List.fromList(
        [destination.x, destination.y, playerId, type.index]);
  }

  /// Deserializes bytes back to Action Object
  /// ActionType identified by 4 byte
  factory Action.deserialize(Uint8List data) {
    switch (ActionType.values[data[3]]) {
      case ActionType.attack:
        return Attack(Point(data[0], data[1]), data[2]);
      case ActionType.move:
        return Move(Point(data[0], data[1]), data[2]);
      case ActionType.heal:
        return Heal(Point(data[0], data[1]), data[2]);
    }
  }
}

class Move extends Action {
  Move(Point<int> dest, int id) : super(ActionType.move, dest, id);
}

class Heal extends Action {
  Heal(Point<int> dest, int id) : super(ActionType.heal, dest, id);
}

class Attack extends Action {
  Attack(Point<int> dest, int id) : super(ActionType.attack, dest, id);
}

enum ActionType { move, attack, heal }
