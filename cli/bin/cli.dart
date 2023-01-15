import 'dart:io';
import 'dart:typed_data';

import 'package:frontend/frontend.dart';
import 'package:frontend/src/observe.dart';
import 'package:shared_models/shared_models.dart';

class CLI extends Observer {
  late GameManager _manager;

  CLI(GameManager manager) {
    _manager = manager;
    _manager.init();
    _manager.registerObserver(this);
  }

  void update() {
    var state = _manager.state;
    if (state != null) {
      var buffer = StringBuffer();
      for (var row in state.field) {
        buffer.write('|');
        for (var entity in row) {
          if (entity != null) {
            switch (entity.type) {
              case EntityType.monster:
                buffer.write('M');
                break;
              case EntityType.player:
                entity as Player;
                print(entity.playerId);
                print(_manager.playerId);
                entity.playerId == _manager.playerId
                    ? buffer.write('O')
                    : buffer.write('P');
                break;
              default:
            }
          } else {
            buffer.write('_');
          }
          buffer.write('|');
        }
        buffer.write('\n');
      }
      print(buffer.toString());
    }
  }
}

void main(List<String> arguments) async {
  GameManager manager = GameManager();

  CLI(manager);
}
