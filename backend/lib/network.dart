import 'dart:io';
import 'package:server/client_info.dart';
import 'package:shared_models/shared_models.dart';

/// Class handeling all UDP/TCP traffic to Clients
class Network {
  /// udpPort to listen on
  static const udpPort = 25569;

  /// List with all connected Clients
  var clients = List<ClientInfo>.empty(growable: true);

  /// Udp Socket
  late RawDatagramSocket udpSocket;

  Network(this.udpSocket);

  /// Methode to add a Client
  /// Adds client to list
  /// then send the client his ID over TCP
  void addClient(ClientInfo clientInfo) async {
    clients.add(clientInfo);
    clientInfo.clientTcp?.add(SendId(clientInfo.player.playerId).serialize());
    await clientInfo.clientTcp?.flush();
  }

  /// helper function to send Data to all connected Clients
  void _sendAll(List<int> data) {
    for (var client in clients) {
      if (!client.isOffline) {
        udpSocket.send(data, client.clientIp, client.clientUdpPort);
      }
    }
  }

  /// send the GameState to all Clients
  void sendGameState(GameState state) {
    _sendAll(state.serialize());
  }

  /// Action counters for statistics
  int actions = 0;

  /// Register callback to handle Actions from clients
  /// Extract client Info out of List
  void listen(Future<void> Function(Action action, ClientInfo client) handle) {
    udpSocket.listen((event) async {
      Datagram? datagram = udpSocket.receive();
      if (datagram == null) return;
      var action = Action.deserialize(datagram.data);
      var client = getClientInfo(action.playerId);
      if (client == null) return;
      ++actions;
      await handle(action, client);
    }, onError: (error) {
      print(error);
    });
  }

  /// Get client Info Id
  ClientInfo? getClientInfo(int id) {
    //TODO what if a client can't be found?
    try {
      return clients.firstWhere((client) => client.player.playerId == id);
    } on StateError {
      return null;
    }
  }
}
