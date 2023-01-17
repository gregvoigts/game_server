import 'dart:math';

import 'package:frontend/frontend.dart';
import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('GameManager', () {
    setUp(() {});

    test('FirstInRange', () {
      int range = 4;
      var center = Point(0, 0);
      for (int r = 1; r <= range; r++) {
        for (int x = r; x >= -r; x--) {
          var v = center + Point<int>(x, r - x.abs());
          print(v);
          var v1 = Point(v.x, v.y * -1);
          print(v1);
        }
      }
    });
  });
}
