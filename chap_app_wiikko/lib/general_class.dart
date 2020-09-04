import 'package:chap_app_wiikko/models/user.dart';
import 'package:chap_app_wiikko/ui/pages/home_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralClass {
  static SharedPreferences sharedPreferences;

  static String baseUrl = "https://doxaevent.com/projects/wiikko/v1/";

  static String errorToConnect = "Nous ne parvenons pas à nous connecter sur internet. Veuillez vérifier votre connexion internet et réessayez.";

  static User currentUser;

  static BuildContext generalContext;

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  static HomePageState homePageState;

  static String getToday() {
    String dateTime = DateTime.now().toIso8601String();
    String date = dateTime.substring(0, 10);
    String hour = dateTime.substring(11, 19);
    return "$date $hour";
  }

  static String formatingDate(String date,
      {bool onlyDate = false,
        bool isCreatedDate = false,
        bool isDateNais = false,
        bool removeDepuis = false, bool other = false}) {
    String dif = "";
    if(date.length==10) date += " 00:00:00";
    try {
      DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateFormat dateNaisFormat = DateFormat("dd MMM yyyy");
      DateFormat depuisFormat = DateFormat("dd MMM yyyy à HH:mm:ss");
      DateFormat otherFormat = DateFormat("dd MMM yyyy HH:mm:ss");
      DateFormat hourFormat = DateFormat("HH:mm");
      DateTime d1 = dateTimeFormat.parse(date);
      DateTime d2 = DateTime.now();
      if (onlyDate) return dateFormat.format(d1);
      if (isCreatedDate) return depuisFormat.format(d1);
      if (isDateNais) return dateNaisFormat.format(d1);
      if (other) return otherFormat.format(d1);
      Duration duration = d2.difference(d1);
      int day = duration.inDays;
      int hours = duration.inHours;
      int minutes = duration.inMinutes;
      int secondes = duration.inSeconds;
      if (day > 0) {
        if (day >= 30 && day < 45)
          dif = "Il y'a 1 mois";
        else if (day < 30)
          dif = "Il y a $day Jours";
        else if (day == 1)
          dif = "Hier à ${hourFormat.format(d1)}";
        else {
          dif = "Depuis le ${depuisFormat.format(d1)}";
          if (removeDepuis) dif = "${depuisFormat.format(d1)}";
        }
      } else if (hours > 0) {
        dif = "Il y a $hours h ${minutes - hours * 60} min";
      } else if (minutes > 0) {
        dif = "Il y a $minutes min ${secondes - minutes * 60} sec";
      } else if (secondes >= 5) {
        dif = "Il y a $secondes sec";
      } else {
        dif = "A l'instant";
      }
    } catch (e) {}
    return dif;
  }

}