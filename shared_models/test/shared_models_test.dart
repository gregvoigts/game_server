import 'dart:typed_data';

import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('Serialize/Deserialize GameState', () {
    final gameState = GameState();
    gameState.spawnPlayer();
    gameState.spawnMonster;

    setUp(() {
      // Additional setup goes here.
    });

    test('Test serialize', () {
      var ser = gameState.serialize();
      expect(ser[0] == gameState.playerCount, isTrue);
      expect(ser[1] == gameState.monsterCount, isTrue);
      expect(ser[2] == (gameState.gameRunning ? 1 : 0), isTrue);
      expect((ser.length - 3) % 9 == 0, isTrue);
    });

    test('Test deserialize', () {
      var ser = gameState.serialize();
      var des = GameState.deserialize(Uint8List.fromList(ser));
      expect(des.playerCount == gameState.playerCount, isTrue);
      expect(des.monsterCount == gameState.monsterCount, isTrue);
      expect(des.gameRunning == gameState.gameRunning, isTrue);
    });
  });
}
