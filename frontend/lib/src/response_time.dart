class ResponseTime {
  int actionId;

  late int sendTime;
  int? recieveTime;

  ResponseTime(this.actionId) {
    sendTime = DateTime.now().millisecondsSinceEpoch;
  }
}
