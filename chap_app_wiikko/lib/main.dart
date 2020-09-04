import 'package:chap_app_wiikko/general_class.dart';
import 'package:chap_app_wiikko/models/user.dart';
import 'package:chap_app_wiikko/ui/pages/connection_page.dart';
import 'package:chap_app_wiikko/ui/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

Widget _defaultHome;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _defaultHome = new ConnectionPage();

  GeneralClass.sharedPreferences = await SharedPreferences.getInstance();

  User user = User.myProfileFromSharedPreference();
  if (user != null) {
    GeneralClass.currentUser = user;
    _defaultHome = HomePage();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wiikko Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: _defaultHome,
    );
  }
}
