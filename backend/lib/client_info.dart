import 'dart:io';
import 'package:shared_models/shared_models.dart';

class ClientInfo {
  InternetAddress clientIp;
  Socket clientTcp;
  int clientUdpPort;
  Player player;
  bool isOffline = false;

  ClientInfo(this.clientIp, this.clientTcp, this.player,
      {this.clientUdpPort = 25568});
}
