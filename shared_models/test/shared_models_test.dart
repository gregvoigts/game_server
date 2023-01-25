import 'dart:math';
import 'dart:typed_data';

import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('Serialize/Deserialize Monster', () {
    final monster = Monster(2, Point(2, 2));

    setUp(() {
      // Additional setup goes here.
    });

    test('Test serialize', () {
      var ser = monster.serialize();
      expect(ser[0] == monster.type.index, isTrue);
      expect(ser[1] == monster.health, isTrue);
      expect(ser[2] == monster.ap, isTrue);
      expect(ser[3] == monster.maxHealth, isTrue);
      expect(ser[4] == monster.pos.x, isTrue);
      expect(ser[5] == monster.pos.y, isTrue);
      expect(ser[6] == monster.playerId, isTrue);
      expect(ser.length == 7, isTrue);
    });

    test('Test deserialize', () {
      var ser = monster.serialize();
      var des = Entity.deserialize(Uint8List.fromList(ser));
      expect(des.type == monster.type, isTrue);
      expect(des.health == monster.health, isTrue);
      expect(des.ap == monster.ap, isTrue);
      expect(des.maxHealth == monster.maxHealth, isTrue);
      expect(des.pos == monster.pos, isTrue);
    });
  });
  group('Serialize/Deserialize Player', () {
    final player = Player(1, Point(2, 2));

    setUp(() {
      // Additional setup goes here.
    });

    test('Test serialize', () {
      var ser = player.serialize();
      expect(ser[0] == player.type.index, isTrue);
      expect(ser[1] == player.health, isTrue);
      expect(ser[2] == player.ap, isTrue);
      expect(ser[3] == player.maxHealth, isTrue);
      expect(ser[4] == player.pos.x, isTrue);
      expect(ser[5] == player.pos.y, isTrue);
      expect(ser[6] == player.playerId, isTrue);
      expect(ser.length == 7, isTrue);
    });

    test('Test deserialize', () {
      var ser = player.serialize();
      var des = Entity.deserialize(Uint8List.fromList(ser));
      expect(des.type == player.type, isTrue);
      expect(des.health == player.health, isTrue);
      expect(des.ap == player.ap, isTrue);
      expect(des.maxHealth == player.maxHealth, isTrue);
      expect(des.pos == player.pos, isTrue);
      expect((des as Player).playerId == player.playerId, isTrue);
    });
  });
  group('Serialize/Deserialize GameState', () {
    final gameState = GameState();
    gameState.spawnPlayer(1);
    gameState.spawnMonster(2);

    setUp(() {
      // Additional setup goes here.
    });

    test('Test serialize', () {
      var ser = gameState.serialize();
      expect(ser[0] == gameState.playerCount, isTrue);
      expect(ser[1] == gameState.monsterCount, isTrue);
      expect(ser[2] == (gameState.gameRunning ? 1 : 0), isTrue);
      expect((ser.length - 5) % 9 == 0, isTrue);
    });

    test('Test deserialize', () {
      var ser = gameState.serialize();
      var des = GameState.deserialize(Uint8List.fromList(ser));
      expect(des.playerCount == gameState.playerCount, isTrue);
      expect(des.monsterCount == gameState.monsterCount, isTrue);
      expect(des.gameRunning == gameState.gameRunning, isTrue);
    });
  });

  group('Serialize/Deserialize Actions', () {
    var move = Move(Point(2, 2), 1, actionId: 1);
    var heal = Heal(Point(3, 1), 1, actionId: 2);
    var attack = Attack(Point(4, 6), 1, actionId: 3);
    test('Test serialize', () {
      var moveSer = move.serialize();
      expect(moveSer[0] == move.destination.x, isTrue);
      expect(moveSer[1] == move.destination.y, isTrue);
      expect(moveSer[2] == move.playerId, isTrue);
      expect(moveSer[3] == move.type.index, isTrue);
      expect(moveSer[4] == move.actionId, isTrue);

      var healSer = heal.serialize();
      expect(healSer[0] == heal.destination.x, isTrue);
      expect(healSer[1] == heal.destination.y, isTrue);
      expect(healSer[2] == heal.playerId, isTrue);
      expect(healSer[3] == heal.type.index, isTrue);
      expect(healSer[4] == heal.actionId, isTrue);

      var attackSer = attack.serialize();
      expect(attackSer[0] == attack.destination.x, isTrue);
      expect(attackSer[1] == attack.destination.y, isTrue);
      expect(attackSer[2] == attack.playerId, isTrue);
      expect(attackSer[3] == attack.type.index, isTrue);
      expect(attackSer[4] == attack.actionId, isTrue);
    });

    test('Test deserialize', () {
      var moveSer = move.serialize();
      var moveDes = Action.deserialize(Uint8List.fromList(moveSer));
      expect(moveDes.destination == move.destination, isTrue);
      expect(moveDes.type == move.type, isTrue);
      expect(moveDes.playerId == move.playerId, isTrue);
      expect(moveDes.actionId == move.actionId, isTrue);

      var healSer = heal.serialize();
      var healDes = Action.deserialize(Uint8List.fromList(healSer));
      expect(healDes.destination == heal.destination, isTrue);
      expect(healDes.type == heal.type, isTrue);
      expect(healDes.playerId == heal.playerId, isTrue);
      expect(healDes.actionId == heal.actionId, isTrue);

      var attackSer = attack.serialize();
      var attackDes = Action.deserialize(Uint8List.fromList(attackSer));
      expect(attackDes.destination == attack.destination, isTrue);
      expect(attackDes.type == attack.type, isTrue);
      expect(attackDes.playerId == attack.playerId, isTrue);
      expect(attackDes.actionId == attack.actionId, isTrue);
    });
  });

  group('Serialize/Deserialize ServerActions', () {
    var send = SendId(1);

    test('Test serialize', () {
      var sendSer = send.serialize();
      expect(sendSer[0] == send.type.index, isTrue);
      expect(sendSer[1] == send.playerId, isTrue);
    });

    test('Test deserialize', () {
      var sendSer = send.serialize();
      var sendDes = ServerAction.deserialize(Uint8List.fromList(sendSer));
      expect(sendDes.type == send.type, isTrue);
      sendDes as SendId;
      expect(sendDes.playerId == send.playerId, isTrue);
    });
  });
}
