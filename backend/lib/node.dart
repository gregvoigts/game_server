import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:server/client_info.dart';
import 'package:server/network.dart';
import 'package:server/node_sync.dart';
import 'package:server/sync_actions.dart';
import 'package:shared_models/shared_models.dart';

///Class with all functions and Variables a GameNode need
class Node {
  /// Monster count to spawn
  static const monsterCount = 5;

  /// Count of Server Nodes
  static const nodes = 5;

  /// Global Game_state
  GameState? gameState;

  /// Global network manager
  late Network network;

  /// Global NodeSync
  late NodeSync nodeSync;

  /// StartId for this Node
  late int nextId;

  Node() {
    nextId = int.parse(Platform.environment["FIRST_ID"]!);
  }

  /// Creates the GameState Object and Spawns Monster
  void createGameState() {
    gameState = GameState();
    for (var i = 0; i < monsterCount; i++) {
      gameState!.spawnMonster(nextId);
      nextId += nodes;
    }
  }

  ///Function to Start the Servers GameLoop
  ///Server listens for new Players over TCP
  ///and for Client Actions over UDP
  void start() async {
    await connectNodes();
    listenForNewConnections();

    // Start the Network component
    network = Network(
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, Network.udpPort));

    // Add action Handler to Network component
    network.listen((action, client) async {
      var ret = await handleAction(action, client);
      network.sendGameState(gameState!);
      return ret;
    });
  }

  /// Function to run the Connection Prozess to other nodes
  Future<void> connectNodes() async {
    nodeSync = NodeSync(handleSync, gameState);
    // Establish Connections
    // If no other node is running yet, Create GameState on this Node
    if (await nodeSync.establishConnections()) {
      createGameState();
    }
    // ASk for GameState until get it
    int selector = 0;
    while (gameState == null) {
      print("dont have GameState yet");
      var sock = nodeSync.nodes.values.toList()[selector];
      sock.add(AskGameState().serialize());
      await sock.flush();
      await Future.delayed(Duration(milliseconds: 1000));
      selector++;
      selector = selector % nodeSync.nodes.length;
    }
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
      (Uint8List data) async {
        var connStr = utf8.decode(data);
        var connAr = connStr.split(':');
        var port = int.parse(connAr[1]);
        if (connAr[0] == "localhost" || connAr[0] == "127.0.0.1") {
          connAr[0] = "host.docker.internal";
        }
        // We excpect the First Message to be the clients UDP port
        if (isFirst) {
          if (network != null) {
            // After the First message spwan new Player
            var player = gameState!.spawnPlayer(nextId);
            nextId += monsterCount;
            // If no Player could be Spawned close Connection
            if (player == null) {
              client.destroy();
              return;
            }
            c = ClientInfo(
                (await InternetAddress.lookup(connAr[0]))[0], client, player,
                clientUdpPort: port);
            // Add client info and send the Updated Gamestate to all Clients
            network.addClient(c!);
            network.sendGameState(gameState!);
            nodeSync
                .sendToAll(NewClient(c!.clientUdpPort, c!.clientIp, player));
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
  Future<void> handleAction(Action action, ClientInfo client) async {
    print('Got Action : ${action.type} from player ${client.player.playerId}');
    if (!gameState!.isValidPosition(action.destination)) return;
    Entity? target = gameState!.getField(action.destination);

    switch (action.type) {
      case ActionType.heal:
        if (target == null || target.runtimeType != Player) break;
        target as Player;
        await nodeSync.sendToAll(ServerHeal(target.playerId, client.player.ap));
        gameState!.heal(client.player.ap, target);
        break;
      case ActionType.attack:
        if (target == null || target.runtimeType != Monster) break;
        await nodeSync.sendToAll(ServerHurt(target.playerId, client.player.ap));
        gameState!.attack(client.player.ap, target);
        break;
      case ActionType.move:
        if (target != null) break;
        await nodeSync
            .sendToAll(ServerMove(client.player.playerId, action.destination));
        gameState!.move(client.player, action.destination);
        break;
    }
  }

  /// Handle SyncActions from other nodes
  void handleSync(SyncAction action, Socket node) {
    print('Got Sync : ${action.type} from node ${node.remoteAddress.host}');
    if (action.type == SyncType.askGameState && gameState != null) {
      // Send GameState to node Asking
      node.add(SendGamestate(gameState!).serialize());
      return;
    }
    if (action.type == SyncType.gameState) {
      // Set gameState to the recieved one
      gameState = (action as SendGamestate).state;
      return;
    }
    if (action.type == SyncType.newClient) {
      // Create new ClientInfo for connected Client
      action as NewClient;
      network.clients.add(ClientInfo(action.clientIp, null, action.player,
          clientUdpPort: action.udpPort));
      // Spawn player in field
      // TODO: if field is blocked, send Move Action to next free Position
      gameState!.field[action.player.pos.y][action.player.pos.x] =
          action.player;
      gameState!.playerCount++;
      return;
    }
    // Get Entity from Action by ID
    action as GameActionSync;
    //print('Action for Player ${action.entityId}');
    Entity? e;
    for (var row in gameState!.field) {
      for (var cell in row) {
        if (cell != null &&
            cell.runtimeType == Player &&
            cell.playerId == action.entityId) {
          e = cell;
          break;
        }
        if (e != null) {
          break;
        }
      }
    }
    // maybe already dead
    if (e == null) {
      return;
    }
    // Execute Actions on GameState
    switch (action.type) {
      case SyncType.heal:
        action as ServerHeal;
        gameState!.heal(action.power, e as Player);
        break;
      case SyncType.hurt:
        action as ServerHurt;
        gameState!.attack(action.damage, e);
        break;
      case SyncType.move:
        action as ServerMove;
        // if Move action isnt allowed
        // send command to revert move
        if (gameState!.canMove(e as Player, action.dest, overrideRange: true)) {
          gameState!.move(e, action.dest);
        } else {
          nodeSync.sendToAll(ServerMove(e.playerId, e.pos));
        }
        break;
      default:
        assert(false, "Never reached");
    }
  }
}
