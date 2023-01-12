import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:frontend/src/game_manager.dart';
import 'package:shared_models/shared_models.dart';

class Network {
  static const host = "127.0.0.1";
  static const port = 25569;
  RawDatagramSocket socket;
  GameManager gm;

  Network(this.socket, this.gm) {
    socket.listen((event) {
      Datagram? datagram = socket.receive();
      if (datagram == null) return;
      gm.handleDataUpdates(datagram.data);
    });
  }

  void connectToServer() async {
    var tcpSocket = await Socket.connect(host, port);
    tcpSocket.listen(
      // handle data from the server
      (Uint8List data) {
        // Set game State
        gm.handleDataUpdates(data);
        tcpSocket.destroy();
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
  }

  void sendAction(Action action) {
    socket.send(action.serialize(), InternetAddress(host), port);
  }
}
