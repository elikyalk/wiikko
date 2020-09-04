import 'dart:convert';
import 'dart:io';

import 'package:chap_app_wiikko/database/database.dart';
import 'package:chap_app_wiikko/general_class.dart';
import 'package:chap_app_wiikko/models/message.dart';
import 'package:chap_app_wiikko/models/message_dao.dart';
import 'package:http/http.dart' as http;

class MessageDataSync {

  static Future<dynamic> getList(int offset) async {
    String url = GeneralClass.baseUrl + "message/list/${GeneralClass.currentUser.authCode}?offset=$offset";
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(response.body);
        if (map["error"]) {
          return "${map["errorMessage"]}\n${map["errorCode"]}.";
        } else {
          List list = map["liste"];
          List<Message> userList = [];
          List<MessageInterne> userList2 = [];
          for(int i=0; i<list.length; i++) {
            Message msg = Message.fromJson(list[i]);
            MessageInterne msgi = MessageInterne.fromMap(list[i]);
            userList.add(msg);
            userList2.add(msgi);
            await AppDatabase.getInstance().insertNewMessage(msg);
            await MessageDAO.getInstance().ajouter(msgi);
          }
          return userList2;
        }
      }
    } on SocketException {
      return GeneralClass.errorToConnect;
    } catch (ex) {
      throw "Une erreur inconnue est survenue lors de la recupération des messages. $ex";
    }
  }

  static Future<dynamic> send(String texte) async {
    String url = GeneralClass.baseUrl + "message/send/${GeneralClass.currentUser.authCode}";
    Map<String, dynamic> mapToSend = Map<String, dynamic>();
    mapToSend["texte"] = texte;
    try {
      final response = await http.post(url, body: json.encode(mapToSend));
      Map<String, dynamic> map = json.decode(response.body);
      if (response.statusCode == 200) {
        if (map["error"]) {
          return "${map["errorMessage"]}\n${map["errorCode"]}.";
        } else {
          //Message object = Message.fromJson(map);
          //await AppDatabase.getInstance().insertNewMessage(object);
          MessageInterne msg = MessageInterne.fromMap(map);
          await MessageDAO.getInstance().ajouter(msg);
          return msg;
        }
      } else if (response.statusCode == 404) {
        return "${map["errorMessage"]}\n${map["errorCode"]}.";
      } else {
        return "${map["errorMessage"]}\n${map["errorCode"]}.";
      }
    } on SocketException {
      return GeneralClass.errorToConnect;
    } catch (ex) {
      print(ex);
      throw "Une erreur inconnue est survenue lors de la recupération des messages. $ex";
    }
  }

}
