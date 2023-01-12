import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:server/network.dart';
import 'package:shared_models/shared_models.dart';

const monsterCount = 5;
GameState gameState = GameState();
Isolate? connReciver;
Network? network;
void main(List<String> arguments) async {
  for (var i = 0; i < monsterCount; i++) {
    gameState.spawnMonster();
  }

  ReceivePort newConnPort = ReceivePort();
  newConnPort.listen((message) {
    if (network != null) {
      gameState.spawnPlayer();
      network!.addClientIp(message);
      network!.sendGameState(gameState);
      print("addedclient");
    }
  });
  connReciver =
      await Isolate.spawn(listenForNewConnections, newConnPort.sendPort);

  network = Network(
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, Network.udpPort));

  network!.listen((data) {
    var action = Action.deserialize(data);
    print(action);
  });
}

void listenForNewConnections(SendPort sendPort) async {
// bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 25569);
  print("Server listen for new Clients");
  // listen for clent connections to the server
  server.listen((client) {
    handleConnection(client, sendPort);
  });
}

void handleConnection(Socket client, SendPort sendPort) {
  print('Connection from'
      ' ${client.remoteAddress.address}:${client.remotePort}');
  sendPort.send(client.remoteAddress);
  client.write(200);
}
