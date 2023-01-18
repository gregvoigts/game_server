import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:server/client_info.dart';
import 'package:server/network.dart';
import 'package:server/node.dart';
import 'package:shared_models/shared_models.dart';

void main(List<String> arguments) async {
  Node node = Node();

  node.start();
}
