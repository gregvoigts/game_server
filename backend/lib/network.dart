import 'dart:io';
import 'dart:typed_data';
import 'package:shared_models/shared_models.dart';

class Network {
  static const udpPort = 25569;
  var clientIps = List<InternetAddress>.empty(growable: true);
  late RawDatagramSocket udpSocket;

  Network(this.udpSocket);

  void addClientIp(InternetAddress clientIp) {
    clientIps.add(clientIp);
  }

  void _sendAll(List<int> data) async {
    for (var ip in clientIps) {
      udpSocket.send(data, ip, 25568);
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
