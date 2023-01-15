import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:server/client_info.dart';
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

  listenForNewConnections();

  network = Network(
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, Network.udpPort));

  network!.listen((data) {
    var action = Action.deserialize(data);
    print(action);
  });
}

void listenForNewConnections() async {
// bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 25569);
  print("Server listen for new Clients");
  // listen for clent connections to the server
  server.listen((client) {
    handleConnection(client);
  });
}

void handleConnection(Socket client) {
  print('Connection from'
      ' ${client.remoteAddress.address}:${client.remotePort}');
  if (network != null) {
    var player = gameState.spawnPlayer();
    if (player == null) {
      client.destroy();
      return;
    }
    network!.addClient(ClientInfo(client.remoteAddress, client, player));
    network!.sendGameState(gameState);
    print('addedclient with ID ${player.playerId}');
  } else {
    client.destroy();
  }
}
