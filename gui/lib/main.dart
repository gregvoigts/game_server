import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';
import 'package:gui/entity.dart';
import 'package:shared_models/shared_models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Other LOL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade900,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key}) {
    manager.init();
  }
  final GameManager manager = GameManager();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements Observer {
  TextEditingController controller = TextEditingController();

  void sendCommand() {
    var tokens = controller.text.split(' ');
    // [m]ove [u(p)|d(own)|l(eft)|r(ight)]
    if (tokens.length == 2 && (tokens[0] == "move" || tokens[0] == 'm')) {
      switch (tokens[1]) {
        case "up":
        case "u":
          widget.manager.move(Direction.up);
          break;
        case "down":
        case "d":
          widget.manager.move(Direction.down);
          break;
        case "left":
        case "l":
          widget.manager.move(Direction.left);
          break;
        case "right":
        case "r":
          widget.manager.move(Direction.right);
          break;
        default:
      }
    }
    // [h]eal x y
    if (tokens.length == 3 && (tokens[0] == "heal" || tokens[0] == 'h')) {
      int? x = int.tryParse(tokens[1]);
      int? y = int.tryParse(tokens[2]);
      if (x != null && y != null) {
        widget.manager.heal(Point<int>(x, y));
      }
    }
    // [a]ttack x y
    if (tokens.length == 3 && (tokens[0] == "attack" || tokens[0] == 'a')) {
      int? x = int.tryParse(tokens[1]);
      int? y = int.tryParse(tokens[2]);
      if (x != null && y != null) {
        widget.manager.attack(Point<int>(x, y));
      }
    }
    controller.text = "";
  }

  @override
  void update() {
    setState(() {});
  }

  bool registerd = false;

  @override
  Widget build(BuildContext context) {
    if (!registerd) {
      widget.manager.registerObserver(this);
      registerd = true;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("LOL GUI"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  height: 800,
                  width: 800,
                  child: GridView.count(
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 25,
                    children: List.generate(25 * 25, (index) {
                      var y = index % 25;
                      var x = ((index - y) / 25).round();
                      var entity = widget.manager.state?.field[y][x];
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white)),
                        child: EntityView(
                          entity: entity,
                          manager: widget.manager,
                        ),
                      );
                    }),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 500,
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                      )),
                  ElevatedButton(
                    onPressed: sendCommand,
                    child: const Text("Execute"),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
