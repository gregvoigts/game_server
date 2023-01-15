import 'dart:typed_data';

abstract class ServerAction {
  ServerActionType type;

  ServerAction(this.type);

  List<int> serialize() {
    return [type.index];
  }

  factory ServerAction.deserialize(Uint8List data) {
    switch (ServerActionType.values[data[0]]) {
      case ServerActionType.sendId:
        return SendId(data[1]);
    }
  }
}

class SendId extends ServerAction {
  int playerId;

  SendId(this.playerId) : super(ServerActionType.sendId);

  @override
  List<int> serialize() {
    var list = super.serialize();
    list.add(playerId);
    return list;
  }
}

enum ServerActionType { sendId }
