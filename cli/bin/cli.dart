import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:frontend/frontend.dart';
import 'package:shared_models/shared_models.dart';

class CLI extends Observer {
  late GameManager _manager;

  CLI(GameManager manager) {
    _manager = manager;
    _manager.init();
    _manager.registerObserver(this);
  }

  @override
  void update() async {
    print(Visualize.visualize(_manager));
  }
}

class PlayerBot {
  late GameManager _manager;
  PlayerBot() {
    _manager = GameManager();
    _manager.init();
    _play();
  }

  void _play() async {
    // Wait until game is loaded
    while (_manager.state == null) {
      await Future.delayed(const Duration(seconds: 2));
    }
    // Start gameloop
    while (true) {
      await Future.delayed(Duration(seconds: Random().nextInt(3) + 2));
      if (_manager.state != null) {
        var own = _manager.getOwn();
        if (own == null) {
          return;
        }
        // First try to attack
        var target =
            _manager.getFirstInRange<Monster>(own.pos, GameState.attackRange);
        if (target != null) {
          _manager.attack(target.pos);
          continue;
        }
        // Then try to Heal
        var healTarget =
            _manager.getFirstInRange<Player>(own.pos, GameState.healRange);
        if (healTarget != null && healTarget.health != healTarget.maxHealth) {
          _manager.heal(healTarget.pos);
          continue;
        }

        // If nothing works move
        var num = Random().nextInt(4);
        _manager.move(Direction.values[num]);
      }
    }
  }
}

void main(List<String> arguments) async {
  print(arguments);
  if (arguments.length >= 2 && arguments[0] == "bots") {
    var botsCount = int.tryParse(arguments[1]);
    if (botsCount == null) {
      print("BotCount not a number");
      exit(1);
    }
    print("Start $botsCount bots");
    for (int i = 0; i < botsCount; i++) {
      PlayerBot();
    }
  } else {
    print("Start normal Cli client");
    GameManager manager = GameManager();

    CLI(manager);
  }
}
