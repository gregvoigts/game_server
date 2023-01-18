import 'dart:math';

import 'package:frontend/frontend.dart';
import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  void visualizeList(List<Point<int>> originalPoints, Point<int> c) {
    List<int> xValues = [], yValues = [];
    for (var element in originalPoints) {
      xValues.add(element.x);
      yValues.add(element.y);
    }
    xValues.sort();
    yValues.sort();

    //calculate needed size of the grid
    var size = max(xValues.last + xValues.first.abs() + 1,
        yValues.last + yValues.first.abs() + 1);
    // normalize to display negative values
    var offset = min(xValues.first, yValues.first).abs();
    var normalizedPoints = originalPoints
        .map((e) => e = Point(e.x + offset, e.y + offset))
        .toList();
    // normalize center aswell
    var center = Point(c.x + offset, c.y + offset);

    // print('offset: $offset');
    // print('points: $originalPoints');
    // print('norm. points: $normalizedPoints');
    // print('size: $size');

    var buffer = StringBuffer();
    for (int r = 0; r < size; r++) {
      buffer.write('|');
      for (int c = 0; c < size; c++) {
        var temp = Point(c, r);
        buffer.write(!normalizedPoints.contains(Point(c, r))
            ? '_'
            : (temp == center ? 'O' : 'X'));
        buffer.write('|');
      }
      buffer.write('\n');
    }
    print(buffer.toString());
  }

  group('GameManager', () {
    setUp(() {});

    test('FirstInRange', () {
      int range = 4;
      var center = Point(0, 0);
      List<Point<int>> points = [center];
      for (int r = 1; r <= range; r++) {
        for (int x = r; x >= -r; x--) {
          var v = center + Point<int>(x, r - x.abs());
          print(v);
          var v1 = Point(v.x, v.y * -1);
          print(v1);
          points.addAll([v, v1]);
        }
      }
      visualizeList(points, center);
    });
  });
}
