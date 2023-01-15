import 'package:frontend/frontend.dart';
import 'package:shared_models/shared_models.dart';

class Visualize {
  static visualize(GameManager manager) {
    var state = manager.state;
    if (state != null) {
      var buffer = StringBuffer();
      for (var row in state.field) {
        buffer.write('|');
        for (var entity in row) {
          if (entity != null) {
            switch (entity.type) {
              case EntityType.monster:
                buffer.write('M');
                break;
              case EntityType.player:
                entity as Player;
                manager.isMe(entity.playerId)
                    ? buffer.write('O')
                    : buffer.write('P');
                break;
              default:
            }
          } else {
            buffer.write('_');
          }
          buffer.write('|');
        }
        buffer.write('\n');
      }
      return buffer.toString();
    }
  }
}
