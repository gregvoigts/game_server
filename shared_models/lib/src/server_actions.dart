import 'dart:typed_data';

/// Abstract base class for all Actions the Server sends to Client over TCP
abstract class ServerAction {
  ServerActionType type;

  ServerAction(this.type);

  /// Serialize all Information
  List<int> serialize() {
    return [type.index];
  }

  /// Deserialize back to GameObject
  factory ServerAction.deserialize(Uint8List data) {
    switch (ServerActionType.values[data[0]]) {
      case ServerActionType.sendId:
        return SendId(data[1]);
    }
  }
}

/// Action Server sends to Client with players Id
class SendId extends ServerAction {
  int playerId;

  SendId(this.playerId) : super(ServerActionType.sendId);

  /// overrides serialize Function and add id to Bytelist
  @override
  List<int> serialize() {
    var list = super.serialize();
    list.add(playerId);
    return list;
  }
}

enum ServerActionType { sendId }
