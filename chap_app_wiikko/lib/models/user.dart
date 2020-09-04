import 'dart:convert';

import 'package:chap_app_wiikko/backend/message_datasync.dart';
import 'package:chap_app_wiikko/general_class.dart';

class User {
  static final ID = "id";
  static final USERNAME = "userName";
  static final AUTH_CODE = "authCode";
  static final URL_PHOTO = "urlPhoto";
  static final URL_THUMBNAIL = "urlThumbnail";
  static final CREATING_TIME = "creatingTime";
  static final PASSWORD = "password";

  bool error = false;
  String errorCode = "";
  String errorMessage = "";
  int id = -1;
  String username = "";
  String authCode = "";
  String urlPhoto = "";
  String urlThumbnail = "";
  String creatingTime = "";
  String password = "";

  User();

  Map<String, dynamic> toMap() {
    Map<String, String> map = new Map();
    map[ID] = this.id.toString();
    map[USERNAME] = this.username;
    map[PASSWORD] = this.password.toString();
    map[AUTH_CODE] = this.authCode;
    map[URL_PHOTO] = this.urlPhoto;
    map[URL_THUMBNAIL] = this.urlThumbnail;
    return map;
  }

  static fromMap(Map map, {bool isFromServer = false}) {
    User user = User();
    if (map['error'] != null) user.error = map['error'];
    if (map['errorCode'] != null) user.errorCode = map['errorCode'].toString();
    if (map['errorMessage'] != null) user.errorMessage = map['errorMessage'];
    if (map[ID] != null) user.id = int.parse(map[ID].toString());
    if (map[USERNAME] != null) user.username = map[USERNAME];
    if (map[AUTH_CODE] != null) user.authCode = map[AUTH_CODE];
    if (map[URL_PHOTO] != null) user.urlPhoto = map[URL_PHOTO];
    if (map[URL_THUMBNAIL] != null) user.urlThumbnail = map[URL_THUMBNAIL];
    if (map[CREATING_TIME] != null) user.creatingTime = map[CREATING_TIME];
    return user;
  }

  static myProfileFromSharedPreference() {
    if(GeneralClass.sharedPreferences.containsKey("profile")) {
      String data = GeneralClass.sharedPreferences.getString("profile");
      if(data!=null && data.isNotEmpty) {
        try{
          Map map = json.decode(data);
          User user=User.fromMap(map);
          return user;
        }catch(e){

        }
      }
    }
    return null;
  }

  @override
  bool operator ==(other) {
    if (this.id == other.id) return true;
    return false;
  }

  @override
  int get hashCode => id;

}
