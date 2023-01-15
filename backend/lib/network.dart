import 'dart:io';
import 'dart:typed_data';
import 'package:server/client_info.dart';
import 'package:shared_models/shared_models.dart';

class Network {
  static const udpPort = 25569;
  var clients = List<ClientInfo>.empty(growable: true);
  late RawDatagramSocket udpSocket;

  Network(this.udpSocket);

  void addClient(ClientInfo clientInfo) async {
    clients.add(clientInfo);
    clientInfo.clientTcp.add(SendId(clientInfo.player.playerId).serialize());
    await clientInfo.clientTcp.flush();
  }

  void _sendAll(List<int> data) async {
    for (var client in clients) {
      udpSocket.send(data, client.clientIp, client.clientUdpPort);
    }
  }

  void sendGameState(GameState state) async {
    _sendAll(state.serialize());
  }

  void listen(void Function(Uint8List datan, ClientInfo sender) handle) {
    udpSocket.listen((event) {
      Datagram? datagram = udpSocket.receive();
      if (datagram == null) return;
      var client = getClientInfo(datagram.address);
      if (client == null) return;
      handle(datagram.data, client);
    });
  }

  ClientInfo? getClientInfo(InternetAddress clientIp) {
    //TODO what if a client can't be found?
    try{
      return clients.firstWhere((client) => 
        client.clientIp == clientIp
      );
    }
    on StateError{
      return null;
    }
  }
}
