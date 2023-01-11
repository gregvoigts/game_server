import 'dart:math';

class Util {
  static int calcDistance(Point<int> from, Point<int> to) {
    return (from.x - to.x).abs() + (from.y - to.y).abs();
  }
}
