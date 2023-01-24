import 'dart:io';

import 'package:mutex/mutex.dart';
import 'package:server/sync_actions.dart';
import 'package:shared_models/shared_models.dart';

/// Class for all Traffik between Server Nodes
class NodeSync {
  /// Port used by nodes to Sync with others
  static const int syncPort = 25542;

  /// List of all the Hostnames of nodes
  Map<String, bool> nodeList = {
    //"127.0.0.1": true,
    "node_0.game_server": true,
    "node_1.game_server": true,
    "node_2.game_server": true,
    "node_3.game_server": true,
    "node_4.game_server": true
  };

  /// List with TCP Sockets to all server Nodes
  Map<String, Socket> nodes = {};

  /// Methode to handle SyncActions from other nodes
  void Function(SyncAction action, Socket node) onData;

  NodeSync(this.onData, GameState? state) {
    // Check if OWN_HOST is set
    var ownHost = Platform.environment["OWN_HOSTNAME"];
    if (ownHost == null) {
      throw Exception("OWN_HOSTNAME isnt set");
    }
    if (!nodeList.keys.contains(ownHost)) {
      throw Exception("OWN_HOSTNAME not in list of nodes");
    }

    // connect to all Nodes under your own
    for (var key in nodeList.keys) {
      if (key == ownHost) {
        break;
      }
      nodeList[key] = false;
    }

    // Start to listen for new TCP connections from other Nodes
    ServerSocket.bind(ownHost, syncPort).then((sSocket) {
      print("Listen for Nodes");
      sSocket.listen((node) async {
        // Performe reverse Lookup to get hostname
        var address = await node.remoteAddress.reverse();
        // Search for Node in List
        if (!nodeList.keys.contains(address.host)) {
          // If Node isnt in List of Hostnames, dont accept connection
          print(
              'Connection from not known Host: ${address.host}. Stopping connection');
          node.destroy();
          return;
        }
        // Dont accept Connection if node has already Connection
        if (nodes.containsKey(address.host)) {
          print('Connection always present: ${address.host}.');
          node.destroy();
          return;
        }
        // Accept Connection
        listenSocket(node);
        nodes[address.host] = node;
        // Send gameState to new Node if present
        if (state != null) {
          node.add(SendGamestate(state).serialize());
        }
        print('Connected to ${address.host}');
      });
    });
  }

  /// This methode adds a listener to a established TCP Connection
  void listenSocket(Socket node) {
    node.listen(
      // handle data
      (event) {
        var syncAction = SyncAction.deserialize(event);
        onData(syncAction, node);
      }, // handle errors
      onError: (error) {
        print(error);
      },
      // handle node ending connection
      onDone: () {
        print('node offline. $node');
      },
    );
  }

  final sockMut = Mutex();
  // Send SyncAction to all Connected Nodes
  Future<void> sendToAll(SyncAction action) async {
    await sockMut.protect(() async {
      for (var sock in nodes.values) {
        //print("send update to ${sock.remoteAddress.host}");
        try {
          sock.add(action.serialize());
          await sock.flush();
        } on Exception catch (e) {
          print(e);
          print(action.serialize());
        } finally {}
      }
      return Future.delayed(
        Duration(milliseconds: 1),
      );
    });
  }

  /// Methode to try to establish connections to all other running Nodes under the own node
  /// If the Late flag is set, try to connect to all Hosts
  /// For each connection take 3 trys and wait for 50ms after each try
  /// The return value indicates if at least 1 connection could be established
  Future<bool> establishConnections({bool late = false}) async {
    bool ret = true;
    for (var node in nodeList.keys) {
      if ((nodeList[node]! && !late) ||
          node == Platform.environment["OWN_HOSTNAME"]) {
        continue;
      }
      var trys = 3;
      while (trys > 0) {
        try {
          var sock = await Socket.connect(node, syncPort,
              timeout: Duration(milliseconds: 5));
          nodes[node] = sock;
          listenSocket(sock);
          ret = false;
          print('Connected to $node');
          break;
        } on SocketException {
          print('Node $node is not online yet');
        }
        trys--;
        await Future.delayed(Duration(milliseconds: 50));
      }
    }
    return ret;
  }
}
