import 'dart:math';

/// Utility class for helper functions.
class Util {
  /// Calculate a basic distance of two points on a grid field.
  ///
  /// ```dart
  /// calcDistance(Point<int>(0,0),Point<int>(1,1)) == 2
  /// ```
  static int calcDistance(Point<int> from, Point<int> to) {
    return (from.x - to.x).abs() + (from.y - to.y).abs();
  }

  /// Returns a basic vector corresponding to the given direction.
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
