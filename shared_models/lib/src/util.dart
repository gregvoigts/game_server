import 'dart:math';

class Util {
  static int calcDistance(Point<int> from, Point<int> to) {
    return (from.x - to.x).abs() + (from.y - to.y).abs();
  }

  static Point<int> getVector(Direction dir) {
    switch (dir) {
      case Direction.left:
        return Point(-1, 0);
      case Direction.right:
        return Point(1, 0);
      case Direction.up:
        return Point(0, -1);
      case Direction.down:
        return Point(0, 1);
    }
  }
}

enum Direction { left, right, up, down }
