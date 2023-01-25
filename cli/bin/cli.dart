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
  late GameManager manager;
  late Future<void> gameRunning;
  PlayerBot() {
    manager = GameManager();
    manager.init();
    gameRunning = _play();
  }

  Future<void> _play() async {
    // Wait until game is loaded
    while (manager.state == null) {
      await Future.delayed(const Duration(seconds: 2));
    }
    // Start gameloop
    while (manager.state?.gameRunning ?? false) {
      await Future.delayed(Duration(seconds: Random().nextInt(3) + 3));
      if (manager.state != null) {
        var own = manager.getOwn();
        if (own == null) {
          return;
        }
        // Try to heal player with 50% hp or less
        var healTarget =
            manager.getFirstInRange<Player>(own.pos, GameState.healRange);
        if (healTarget != null &&
            healTarget.health <= healTarget.maxHealth * 0.5) {
          manager.heal(healTarget.pos);
          continue;
        }

        // Then find the closest monster
        var target = manager.getFirstInRange<Monster>(own.pos, -1);
        if (target != null) {
          // and attack if in range ...
          if (Util.calcDistance(own.pos, target.pos) <= GameState.attackRange) {
            manager.attack(target.pos);
            continue;
          }
          // or move closer to the monster
          var moves = target.pos - own.pos;
          if (moves.x.abs() > moves.y.abs()) {
            manager.moveTo(Point((moves.x / moves.x.abs()).ceil(), 0));
          } else {
            manager.moveTo(Point(0, (moves.y / moves.y.abs()).ceil()));
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
    List<PlayerBot> bots = [];
    for (int i = 0; i < botsCount; i++) {
      bots.add(PlayerBot());
      await Future.delayed(Duration(milliseconds: 10));
    }

    // aggregate statistics
    var rtts = <int>[];
    var noResp = 0;
    var sendActions = 0;
    Map<ActionType, int> actionCounts = {};
    for (var bot in bots) {
      await bot.gameRunning;
      var res = bot.manager.getStatistics();
      rtts.addAll(res["RTTs"] as List<int>);
      noResp += res["noResp"] as int;
      sendActions += res["actionsSend"] as int;
      (res["actionCounts"] as Map<ActionType, int>).forEach((key, value) {
        actionCounts[key] = (actionCounts[key] ?? 0) + value;
      });
    }
    var avgRTT = rtts.reduce((int val1, int val2) => val1 + val2) / rtts.length;
    var stats =
        'Stats: AvgRTT: $avgRTT \nActions send: $sendActions \nActions without Response: $noResp';
    actionCounts.forEach((key, value) {
      stats += '\n$key send: $value';
    });
    print(stats);
  } else {
    print("Start normal Cli client");
    GameManager manager = GameManager();

    CLI(manager);
  }
}
