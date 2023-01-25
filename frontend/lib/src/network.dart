import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:frontend/src/game_manager.dart';
import 'package:frontend/src/response_time.dart';
import 'package:shared_models/shared_models.dart';

/// Class handels all network traffik for the Frontend
class Network {
  /// Server address
  static const host = "127.0.0.1";

  /// UDP Port of the Server
  static const port = 25569;

  static int actionId = 0;

  Queue<ResponseTime> responseTimes = Queue();

  /// UDP Socket of the Client
  RawDatagramSocket socket;

  /// Reverenz to the GameManager
  GameManager gm;

  Network(this.socket, this.gm) {
    print(socket.port);
    socket.listen((event) {
      int recTime = DateTime.now().millisecondsSinceEpoch;
      Datagram? datagram = socket.receive();
      if (datagram == null) return;
      var data = GameState.deserialize(datagram.data);
      if (data.playerId == gm.playerId) {
        for (var send in responseTimes) {
          if (send.actionId == data.actionId) {
            send.recieveTime = recTime;
            break;
          }
        }
      }
      gm.handleDataUpdates(data);
    });
  }

  ///Methode to Connect to Server with TCP
  void connectToServer() async {
    var tcpSocket = await Socket.connect(host, port);
    tcpSocket.listen(
      // handle data from the server
      (Uint8List data) {
        // Set game State
        var serverData = ServerAction.deserialize(data);
        if (serverData.runtimeType == SendId) {
          gm.playerId = (serverData as SendId).playerId;
          print('Set player id: ${serverData.playerId}');
        } else {
          print(serverData);
        }
      },

      // handle errors
      onError: (error) {
        print(error);
        tcpSocket.destroy();
      },

      // handle server ending connection
      onDone: () {
        print('Server left.');
        tcpSocket.destroy();
      },
    );

    tcpSocket.write("${socket.address.address}:${socket.port}");
    await tcpSocket.flush();
  }

  int actions = 0;

  /// Send Action to Server with UDP
  void sendAction(Action action) {
    ++actions;
    action.actionId = actionId;
    responseTimes.addFirst(ResponseTime(actionId));
    socket.send(action.serialize(), InternetAddress(host), port);
    actionId++;
    actionId = actionId % 256;
  }
}
