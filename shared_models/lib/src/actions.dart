import 'dart:math';
import 'dart:typed_data';

import 'package:shared_models/shared_models.dart';

abstract class Action {
  ActionType type;
  Point<int> destination;

  Action(this.type, this.destination);

  Uint8List serialize() {
    return Uint8List.fromList([destination.x, destination.y, type.index]);
  }

  factory Action.deserialize(Uint8List data) {
    switch (ActionType.values[data[2]]) {
      case ActionType.attack:
        return Attack(Point(data[0], data[1]));
      case ActionType.move:
        return Move(Point(data[0], data[1]));
      case ActionType.heal:
        return Heal(Point(data[0], data[1]));
    }
  }
}

class Move extends Action {
  Move(Point<int> dest) : super(ActionType.move, dest);
}

class Heal extends Action {
  Heal(Point<int> dest) : super(ActionType.heal, dest);
}

class Attack extends Action {
  Attack(Point<int> dest) : super(ActionType.attack, dest);
}

enum ActionType { move, attack, heal }
