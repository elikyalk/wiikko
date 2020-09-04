import 'dart:convert';

import 'package:chap_app_wiikko/backend/message_datasync.dart';
import 'package:chap_app_wiikko/general_class.dart';
import 'package:chap_app_wiikko/models/message_dao.dart';

class MessageInterne {
  int id = -1;
  String texte = "";
  String username = "";
  String creatingTime = "";
  int idUserFrom = -1;
  int sendState = 1;

  MessageInterne({this.id, this.texte, this.username, this.creatingTime, this.idUserFrom, this.sendState});

  Map<String, dynamic> toMap() {
    Map<String, String> map = new Map();
    map[MessageDAO.KEY] = this.id.toString();
    map[MessageDAO.USERNAME] = this.username;
    map[MessageDAO.ID_USER_FROM] = this.idUserFrom.toString();
    map[MessageDAO.SEND_STATE] = this.sendState.toString();
    map[MessageDAO.CREATING_TIME] = this.creatingTime;
    map[MessageDAO.TEXTE] = this.texte;
    return map;
  }

  static fromMap(Map map, {bool isFromServer = false}) {
    MessageInterne object = MessageInterne();
    if (map[MessageDAO.KEY] != null) object.id = int.parse(map[MessageDAO.KEY].toString());
    if (map[MessageDAO.ID_USER_FROM] != null) object.idUserFrom = int.parse(map[MessageDAO.ID_USER_FROM].toString());
    if (map[MessageDAO.SEND_STATE] != null) object.sendState = int.parse(map[MessageDAO.SEND_STATE].toString());
    if (map[MessageDAO.USERNAME] != null) object.username = map[MessageDAO.USERNAME];
    if (map[MessageDAO.TEXTE] != null) object.texte = map[MessageDAO.TEXTE];
    if (map[MessageDAO.CREATING_TIME] != null) object.creatingTime = map[MessageDAO.CREATING_TIME];
    return object;
  }

  @override
  bool operator ==(other) {
    if (this.id == other.id) return true;
    return false;
  }

  @override
  int get hashCode => id;

}
