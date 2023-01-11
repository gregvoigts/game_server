import 'dart:io';

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
      udpSocket.send(data, ip, 25569);
    }
  }
}
