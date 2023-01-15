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

  void listen(void Function(Uint8List data) handle) {
    udpSocket.listen((event) {
      Datagram? datagram = udpSocket.receive();
      if (datagram == null) return;
      handle(datagram.data);
    });
  }
}
