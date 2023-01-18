import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:server/client_info.dart';
import 'package:server/network.dart';
import 'package:shared_models/shared_models.dart';

///Class with all functions and Variables a GameNode need
class Node {
  /// Monster count to spawn
  static const monsterCount = 5;

  /// Global Game_state
  GameState gameState = GameState();

  /// Global network manager
  Network? network;

  Node() {
    for (var i = 0; i < monsterCount; i++) {
      gameState.spawnMonster();
    }
  }

  ///Function to Start the Servers GameLoop
  ///Server listens for new Players over TCP
  ///and for Client Actions over UDP
  void start() async {
    listenForNewConnections();

    // Start the Network component
    network = Network(
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, Network.udpPort));

    // Add action Handler to Network component
    network!.listen((action, client) {
      handleAction(action, client);
      network!.sendGameState(gameState);
    });
  }

  /// Init TCP socket for new Players
  void listenForNewConnections() async {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 25569);
    print("Server listen for new Clients");
    // listen for clent connections to the server
    server.listen((client) {
      handleConnection(client);
    });
  }

  /// Handels new Player connections
  void handleConnection(Socket client) {
    print('Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}');
    bool isFirst = true;
    // Container for client Info to be accessed by onDone
    ClientInfo? c;
    //Listen to Socket
    client.listen(
      (Uint8List data) {
        var port = int.parse(utf8.decode(data));
        print(port);
        // We excpect the First Message to be the clients UDP port
        if (isFirst) {
          if (network != null) {
            // After the First message spwan new Player
            var player = gameState.spawnPlayer();
            // If no Player could be Spawned close Connection
            if (player == null) {
              client.destroy();
              return;
            }
            c = ClientInfo(client.remoteAddress, client, player,
                clientUdpPort: port);
            // Add client info and send the Updated Gamestate to all Clients
            network!.addClient(c!);
            network!.sendGameState(gameState);
            print('addedclient with ID ${player.playerId}');
          } else {
            // If the Network isnt
            client.destroy();
          }
          isFirst = false;
        } else {
          print(data);
        }
      }, // handle errors
      onError: (error) {
        print(error);
      },

      // handle client ending connection
      onDone: () {
        print('client offline. ${c?.player.playerId}');
        if (c != null) {
          c!.isOffline = true;
        }
        client.destroy();
      },
    );
  }

  /// Methode to handle Actions recieved from client
  void handleAction(Action action, ClientInfo client) {
    print('Got Action : ${action.type} from player ${client.player.playerId}');
    if (!gameState.isValidPosition(action.destination)) return;
    Entity? target = gameState.getField(action.destination);

    switch (action.type) {
      case ActionType.heal:
        if (target == null || target.runtimeType != Player) break;
        target as Player;
        gameState.heal(client.player, target);
        break;
      case ActionType.attack:
        if (target == null || target.runtimeType != Monster) break;
        gameState.attack(client.player, target);
        break;
      case ActionType.move:
        if (target != null) break;
        gameState.move(client.player, action.destination);
        break;
    }
  }
}
