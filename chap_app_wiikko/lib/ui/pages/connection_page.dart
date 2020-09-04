import 'dart:ui' as ui;

import 'package:chap_app_wiikko/backend/user_datasync.dart';
import 'package:chap_app_wiikko/models/user.dart';
import 'package:chap_app_wiikko/ui/pages/home_page.dart';
import 'package:chap_app_wiikko/ui/widgets/loading_alertdialog.dart';
import 'package:chap_app_wiikko/ui/widgets/mes_widgets.dart';
import 'package:chap_app_wiikko/ui/widgets/new_user_page.dart';
import 'package:flutter/material.dart';

import '../../general_class.dart';

class ConnectionPage extends StatefulWidget {
  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  bool _usernameError = false;
  String _usernameErrorMessage = "";
  bool _passwordError = false;
  bool _visiblePassword = false;
  String _passwordErrorMessage = "";
  String _username = "";
  String _password = "";
  bool _isLoading = false;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipPath(
                clipper: WaveClipper2(),
                child: Container(
                  child: Column(),
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0x22ff3a5a), Color(0x22fe494d)])),
                ),
              ),
              ClipPath(
                clipper: WaveClipper3(),
                child: Container(
                  child: Column(),
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0x44ff3a5a), Color(0x44fe494d)])),
                ),
              ),
              ClipPath(
                clipper: WaveClipper1(),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                      ),
                      Image.asset("assets/images/logo2.png", height: 100.0, width: 100.0,),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Wiikko Chat",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 30),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xffff3a5a), Color(0xfffe494d)])),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Material(
              elevation: 2.0,
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: TextField(
                onChanged: _usernameAreChanged,
                cursorColor: Colors.deepOrange,
                decoration: InputDecoration(
                    hintText: "Saisissez votre pseudo ici.",
                    prefixIcon: Material(
                      elevation: 0,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: Icon(
                        Icons.person,
                        color: Colors.red,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 25, vertical: 13)),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Material(
              elevation: 2.0,
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: TextField(
                onChanged: _passwordAreChanged,
                cursorColor: Colors.deepOrange,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: "Saisissez votre mot de passe ici",
                    prefixIcon: Material(
                      elevation: 0,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: Icon(
                        Icons.lock,
                        color: Colors.red,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 25, vertical: 13)),
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    color: Color(0xffff3a5a)),
                child: FlatButton(
                  child: Text(
                    "Se Connecter",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  ),
                  onPressed: () {
                    _connection();
                  },
                ),
              )),
          SizedBox(height: 40,),
          InkWell(
            onTap: _createAccount,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Vous n'avez pas de compte ? ", style: TextStyle(color:Colors.black,fontSize: 12 ,fontWeight: FontWeight.normal),),
                Text("Créer un compte ", style: TextStyle(color:Colors.red, fontWeight: FontWeight.w500,fontSize: 12, decoration: TextDecoration.underline )),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _connection() async {
    bool _error = false;
    String _errorMsg = "";
    if (_username.trim().length<5 || _username.trim().contains(" ")) {
      _errorMsg =
          "Le pseudonyme saisi est incorrect !";
      _error = true;
    } else if (_password.trim().length<8 || _password.trim().contains(" ")) {
      _error = true;
      _errorMsg = "Le mot de passe saisi est incorrect.";
    }
    if (_error) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: MesWidgets.textAvecStyle(_errorMsg), backgroundColor: Colors.red,));
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LoadingAlertDialog(
              contentText: "Connexion en cours...",
              titleText: "Connexion",
            );
          });
      var reponse = await UserDataSync.login(_username.trim(), _password.trim());
      Navigator.pop(context);
      if (reponse is User) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) {
              return new HomePage();
            }), (Route<dynamic> route) => false);
      } else {
        if(!(reponse is String)) _errorMsg = "Une erreur inconnue est survenue lors de la création de votre compte.";
        else _errorMsg = reponse;
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: MesWidgets.textAvecStyle(_errorMsg), backgroundColor: Colors.red,));
      }
    }
  }

  void _createAccount() async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return new NewUserPage();
    }));
  }

  void _usernameAreChanged(String value) {
    _usernameErrorMessage = "";
    setState(() {
      _usernameError = false;
    });
    if (value.trim().length < 5 || value.trim().contains(" ")) {
      _usernameErrorMessage =
      "Votre pseudonyme doit avoir 5 caratères au minimum et ne doit pas contenir d'esace !";
      setState(() {
        _usernameError = true;
      });
    }
    _username = value;
  }

  void _passwordAreChanged(String value) {
    _passwordErrorMessage = "";
    setState(() {
      _passwordError = false;
    });
    if (value.trim().length < 8 || value.trim().contains(" ")) {
      _passwordErrorMessage =
      "Le mot de passe doit avoir 8 caratères au minimum et ne doit pas contenir d'esace !";
      setState(() {
        _passwordError = true;
      });
    }
    _password = value;
  }

}

class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 29 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 60);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 15 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 40);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * .7, size.height - 40);
    var firstControlPoint = Offset(size.width * .25, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 45);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}