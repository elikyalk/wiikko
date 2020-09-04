import 'dart:convert';
import 'dart:io';

import 'package:chap_app_wiikko/general_class.dart';
import 'package:chap_app_wiikko/models/user.dart';
import 'package:http/http.dart' as http;

class UserDataSync {

  static Future<dynamic> createAccount(User user) async {
    String url = GeneralClass.baseUrl + "user/create";
    String body = json.encode(user.toMap());
    print(url);
    print(body);
    try {
      final response = await http.post(url, body: body);
      Map<String, dynamic> map = json.decode(response.body);
      if (response.statusCode == 200) {
        if (map["error"]) {
          return "${map["errorMessage"]}\n${map["errorCode"]}.";
        } else {
          User object = User.fromMap(map);
          GeneralClass.currentUser = object;
          GeneralClass.sharedPreferences.setString("profile", json.encode(object.toMap()));
          return object;
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
      return "Une erreur inconnue est survenue lors de la création de votre compte.\n$ex";
    }
  }

  static Future<dynamic> login(String username, String password) async {
    String url =
        GeneralClass.baseUrl + "login?username=$username&password=$password";
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        User object = User.fromMap(json.decode(response.body), isFromServer: true);
        if (object.error) {
          return "${object.errorMessage}\nCode de l'erreur: ${object.errorCode}";
        } else {
          GeneralClass.currentUser = object;
          GeneralClass.sharedPreferences.setString("profile", json.encode(object.toMap()));
          return object;
        }
      } else {
        return "${json.decode(response.body)["errorMessage"]}\nCode de l'erreur: ${json.decode(response.body)["errorCode"]}";
      }
    } on SocketException {
      return GeneralClass.errorToConnect;
    } catch (ex) {
      return "Une erreur inconnue est survenue lors de votre connexion :\n$ex";
    }
  }

  static Future<dynamic> updateFCMToken(String token) async {
    String url = GeneralClass.baseUrl + "user/fcmtoken/${GeneralClass.currentUser.authCode}?token=$token";
    print(url);
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        if (!json.decode(response.body)["updated"]) {
          print(
              "${json.decode(response.body)["errorMessage"]}\nCode de l'erreur: ${json.decode(response.body)["errorCode"]}");
        } else {
          print("Token updated successfully");
        }
      } else if (response.statusCode == 404) {
        print(
            "L'erreur suivante a été rencontrée :\nCode de l'erreur: ${json.decode(response.body)["errorCode"]}\nMessage de l'erreur: ${json.decode(response.body)["errorMessage"]}");
      } else {
        print(
            "L'erreur suivante a été rencontrée :\nCode de l'erreur: ${json.decode(response.body)["errorCode"]}\nMessage de l'erreur: ${json.decode(response.body)["errorMessage"]}");
      }
    } on SocketException {
      print("Connection error");
    } catch (ex) {
      print("Une erreur inconnue est survenue token :\n$ex");
    }
    return true;
  }

}
