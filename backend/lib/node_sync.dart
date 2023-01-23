import 'dart:io';

import 'package:server/sync_actions.dart';
import 'package:shared_models/shared_models.dart';

/// Class for all Traffik between Server Nodes
class NodeSync {
  /// Port used by nodes to Sync with others
  static const int syncPort = 25542;

  /// List of all the Hostnames of nodes
  Map<String, bool> nodeList = {
    "game_server-node_0-1.game_server": false,
    "game_server-node_1-1.game_server": false,
    "game_server-node_2-1.game_server": false,
    "game_server-node_3-1.game_server": false,
    "game_server-node_4-1.game_server": false
  };

  /// List with TCP Sockets to all server Nodes
  List<Socket> nodes = [];

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
    nodeList[ownHost] = true;
    // Start to listen for new TCP connections from other Nodes
    ServerSocket.bind(ownHost, syncPort)
        .then((sSocket) => sSocket.listen((node) async {
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
              if (nodeList[address.host]!) {
                print('Connection always present: ${address.host}.');
                node.destroy();
                return;
              }
              nodeList[address.host] = true;
              listenSocket(node);
              nodes.add(node);
              // Send gameState to new Node if present
              if (state != null) {
                node.add(SendGamestate(state).serialize());
              }
              print('Connected to ${address.host}');
            }));
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

  void sendToAll(SyncAction action) {
    for (var sock in nodes) {
      print("send update to ${sock.remoteAddress.host}");
      sock.add(action.serialize());
    }
  }

  /// Methode to try to establish connections to all other running Nodes
  /// The return value indicates if at least 1 connection could be established
  Future<bool> establishConnections() async {
    bool ret = true;
    var ownHost = Platform.environment["OWN_HOSTNAME"];
    for (var node in nodeList.keys) {
      if (nodeList[node]!) {
        continue;
      }
      try {
        var sock = await Socket.connect(node, syncPort,
            timeout: Duration(milliseconds: 5));
        nodeList[node] = true;
        nodes.add(sock);
        listenSocket(sock);
        ret = false;
        print('Connected to $node');
      } on SocketException {
        print('Node $node is not online yet');
      }
    }
    return ret;
  }
}
