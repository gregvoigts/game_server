import 'dart:math';
import 'dart:typed_data';

import 'package:shared_models/shared_models.dart';

abstract class Action {
  ActionType type;
  Point<int> destination;
  int playerId;

  Action(this.type, this.destination, this.playerId);

  Uint8List serialize() {
    return Uint8List.fromList(
        [destination.x, destination.y, playerId, type.index]);
  }

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
