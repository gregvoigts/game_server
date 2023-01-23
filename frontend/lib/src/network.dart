import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:frontend/src/game_manager.dart';
import 'package:shared_models/shared_models.dart';

/// Class handels all network traffik for the Frontend
class Network {
  /// Server address
  static const host = "192.168.178.157";

  /// UDP Port of the Server
  static const port = 25569;

  /// UDP Socket of the Client
  RawDatagramSocket socket;

  /// Reverenz to the GameManager
  GameManager gm;

  Network(this.socket, this.gm) {
    print(socket.port);
    socket.listen((event) {
      Datagram? datagram = socket.receive();
      if (datagram == null) return;
      gm.handleDataUpdates(datagram.data);
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

  /// Send Action to Server with UDP
  void sendAction(Action action) {
    socket.send(action.serialize(), InternetAddress(host), port);
  }
}
