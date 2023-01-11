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

  connReciver = await Isolate.spawn(listenForNewConnections, "");

  network = Network(
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, Network.udpPort));
}

void listenForNewConnections(dynamic msg) async {
// bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4567);

  // listen for clent connections to the server
  server.listen((client) {
    handleConnection(client);
  });
}

void handleConnection(Socket client) {
  print('Connection from'
      ' ${client.remoteAddress.address}:${client.remotePort}');

  client.write(gameState);
}

/*void createUDPSocket() async {
  //Step#1 ----------------Creating socket-----------------
  //IP address on network
  final InternetAddress internetAddress = InternetAddress.anyIPv4; //InternetAddress("192.168.3.143");
  //Port on network
  final int port=25569;
  //Binding with socket(IP and port)
  RawDatagramSocket socket = await RawDatagramSocket.bind(internetAddress, port);

  //Step#2 ------------send message on socket---------------------
  print('Sending from ${socket.address.address}:${socket.port}');
  socket.send('This is message from sender through UDP\n'.codeUnits, InternetAddress.loopbackIPv4, uniCastPort);

  //Step#1 ----------------Creating socket-----------------
  //IP address on network
  final InternetAddress internetAddress = InternetAddress.anyIPv4; //InternetAddress("192.168.3.143");
  //Binding with socket(IP and port)
  RawDatagramSocket socket = await RawDatagramSocket.bind(internetAddress, uniCastPort);

  //Step#2 ------------Start listening a socket(IP,Port)---------------------
  print('Going to start listening a socket(${socket.address.address}:${socket.port})');
  socket.listen((RawSocketEvent event){
    Datagram? datagram = socket.receive();
    if (datagram == null) return;
    String message = String.fromCharCodes(datagram.data).trim();
    print('From ${datagram.address.address}:${datagram.port}, Message: $message');
  });

}*/
