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
    while (_manager.state?.gameRunning ?? false) {
      await Future.delayed(Duration(seconds: Random().nextInt(3) + 2));
      if (_manager.state != null) {
        var own = _manager.getOwn();
        if (own == null) {
          return;
        }
        // Try to heal player with 50% hp or less
        var healTarget =
            _manager.getFirstInRange<Player>(own.pos, GameState.healRange);
        if (healTarget != null &&
            healTarget.health <= healTarget.maxHealth * 0.5) {
          _manager.heal(healTarget.pos);
          continue;
        }

        // Then find the closest monster
        var target = _manager.getFirstInRange<Monster>(own.pos, -1);
        if (target != null) {
          // and attack if in range ...
          if (Util.calcDistance(own.pos, target.pos) <= GameState.attackRange) {
            _manager.attack(target.pos);
            continue;
          }
          // or move closer to the monster
          var moves = target.pos - own.pos;
          if (moves.x.abs() > moves.y.abs()) {
            _manager.moveTo(Point((moves.x / moves.x.abs()).ceil(), 0));
          } else {
            _manager.moveTo(Point(0, (moves.y / moves.y.abs()).ceil()));
          }
        }
        // there should at least be a monster to move to...
        // otherwise the game should be over
        assert(false, 'nothing to do... how strange?!');
      }
    }
    print("Game Finished");
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
