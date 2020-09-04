//import 'dart:isolate';
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:chap_app_wiikko/backend/message_datasync.dart';
import 'package:chap_app_wiikko/database/database.dart';
import 'package:chap_app_wiikko/models/message.dart';
import 'package:chap_app_wiikko/models/message_dao.dart';
import 'package:chap_app_wiikko/models/user.dart';
import 'package:chap_app_wiikko/ui/widgets/mes_widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chap_app_wiikko/general_class.dart';
import 'package:chap_app_wiikko/backend/user_datasync.dart';

Future<void> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    ManageNotification.getInstance().process(message, from: "onBackground");
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _loadingMore = false;
  List<MessageInterne> _messageList = [];
  String _errorMessage = "";
  ScrollController _scrollController = new ScrollController();
  TextEditingController _messageController = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _initializeFirebase();
    super.initState();
    GeneralClass.homePageState = this;
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _initializeFirebase() {
    GeneralClass.firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    GeneralClass.firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
    GeneralClass.firebaseMessaging.requestNotificationPermissions();
    GeneralClass.firebaseMessaging.getToken().then((String token) async {
      if (token != null) {
        if (GeneralClass.sharedPreferences == null)
          GeneralClass.sharedPreferences =
              await SharedPreferences.getInstance();
        if (GeneralClass.sharedPreferences.containsKey("fcmToken")) {
          String lastToken =
              GeneralClass.sharedPreferences.getString("fcmToken");
          if (lastToken == token) return;
        } else {
          GeneralClass.sharedPreferences.setString("fcmToken", token);
        }
        UserDataSync.updateFCMToken(token);
      }
    });
    GeneralClass.firebaseMessaging.onTokenRefresh
        .listen((String newToken) async {
      if (newToken != null) {
        if (GeneralClass.sharedPreferences == null)
          GeneralClass.sharedPreferences =
              await SharedPreferences.getInstance();
        if (GeneralClass.sharedPreferences.containsKey("fcmToken")) {
          String lastToken =
              GeneralClass.sharedPreferences.getString("fcmToken");
          if (lastToken == newToken) return;
        } else {
          GeneralClass.sharedPreferences.setString("fcmToken", newToken);
        }
        UserDataSync.updateFCMToken(newToken);
      }
    });
    GeneralClass.firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> msg) async {
        if (msg["data"] != null) {
          print("onMessage data ok: $msg");
          ManageNotification.getInstance().process(msg, from: "onMessage");
        } else {
          print("onMessage not data: $msg");
        }
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> msg) async {
        print("onLaunch: $msg");
        if (msg["data"] != null)
          ManageNotification.getInstance().process(msg, from: "onLaunch");
      },
      onResume: (Map<String, dynamic> msg) async {
        print("onResume: $msg");
        if (msg["data"] != null)
          ManageNotification.getInstance().process(msg, from: "onResume");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double taille = MediaQuery.of(context).size.width - 100;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromRGBO(250, 240, 230, 1),
      appBar: AppBar(
        leading: Padding(padding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0), child: Image.asset("assets/images/logo2.png"),),
        title: Text("Wiikko Chat"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: ListView.builder(
                itemBuilder: (BuildContext bc, int index) {
                  MessageInterne message = _messageList[index];
                  return _buildItem(message);
                },
                itemCount: _messageList.length,
                reverse: true,
              ),
            ),
          ),
          _buildInputBloc(),
        ],
      ),
    );
  }

  _buildInputBloc() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40))),
        child: Row(
          children: <Widget>[
            //Padding(
            //  padding: EdgeInsets.only(left: 10.0,),
            //  child: MesWidgets.buildAvatar(
            //    GeneralClass.currentUser.urlThumbnail,
            //    size: 50.0,
            //    backColor: Colors.blue,
            //  ),
            //),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Tapez votre message ici.",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
              ),
            ),
            IconButton(icon: Icon(Icons.send), onPressed: () => _sendMessage()),
          ],
        ),
      ),
    );
  }

  _sendMessage() async {
    if (_messageController.text.trim().length == 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: MesWidgets.textAvecStyle("Vous devez saisir un message SVP !"),
      ));
      return;
    }
    int randomId = _messageList.length;
    MessageInterne message = MessageInterne(
        id: randomId,
        texte: _messageController.text.trim(),
        idUserFrom: GeneralClass.currentUser.id,
        username: GeneralClass.currentUser.username,
        creatingTime: GeneralClass.getToday(),
        sendState: 1);

    setState(() {
      _messageList.insert(0, message);
    });
    _messageController.text = "";
    dynamic result = await MessageDataSync.send(message.texte);
    if (result is MessageInterne) {
      setState(() {
        _messageList[_messageList.length - randomId - 1] = result;
      });
    } else {
      MessageInterne message2 = MessageInterne(
          id: randomId,
          texte: message.texte,
          idUserFrom: GeneralClass.currentUser.id,
          username: GeneralClass.currentUser.username,
          creatingTime: message.creatingTime,
          sendState: 2);
      setState(() {
        _messageList[_messageList.length - randomId - 1] = message2;
      });
      if (!(result is String))
        result = "Impossible d'envoyer le message : ${message.texte}";
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: MesWidgets.textAvecStyle(result),
      ));
    }
  }

  void loadData({bool onLaunch=false}) async {
    try{
      await ManageNotification.flutterLocalNotificationsPlugin.cancelAll();
    }catch(e){

    }
    print("loadMore 1");
    if (!mounted || _loadingMore) return;
    print("loadMore 2");
    setState(() {
      _loadingMore = true;
    });
    if(onLaunch) {
      setState(() {
        _messageList=[];
      });
    }
    int offset = onLaunch ? 0 : _messageList.length;
    List<MessageInterne> messageList =
        await MessageDAO.getInstance().findAll(offset);
    if (messageList.length == 0) {
      dynamic result = await MessageDataSync.getList(offset);
      if (result is List<MessageInterne>)
        messageList = result;
      else {
        if (!(result is String))
          result = "Impossible de charger les anciens messages.";
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: MesWidgets.textAvecStyle(result),
          backgroundColor: Colors.red,
        ));
      }
    }
    setState(() {
      _messageList = messageList;
    });
    setState(() {
      _loadingMore = false;
    });
  }

  Widget _buildItem(MessageInterne message) {
    return Container(
      padding: message.idUserFrom == GeneralClass.currentUser.id
          ? EdgeInsets.only(left: 80.0, top: 5.0, bottom: 5.0)
          : EdgeInsets.only(right: 80.0, top: 5.0, bottom: 5.0),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: message.idUserFrom == GeneralClass.currentUser.id ? Radius.circular(10) : Radius.circular(0), bottomRight: message.idUserFrom == GeneralClass.currentUser.id ? Radius.circular(0) : Radius.circular(10))),
        color: message.idUserFrom == GeneralClass.currentUser.id
            ? Colors.blue[100]
            : Colors.green[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MesWidgets.textAvecStyle(
                      message.idUserFrom == GeneralClass.currentUser.id
                          ? "Vous"
                          : message.username,
                      color: Colors.black,
                      textSize: 16.0,
                      fontWeight: FontWeight.bold),
                  MesWidgets.textAvecStyle(
                      GeneralClass.formatingDate(message.creatingTime),
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      textSize: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[],
                  ),
                  Divider(
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: MesWidgets.textAvecStyle(message.texte,
                            color: Colors.black, textSize: 14.0),
                      ),
                      Visibility(
                        visible:
                            message.idUserFrom == GeneralClass.currentUser.id,
                        child: Icon(
                          message.sendState == 0
                              ? Icons.check
                              : message.sendState == 1
                                  ? Icons.autorenew
                                  : Icons.block,
                          color: message.sendState == 0
                              ? Colors.green
                              : message.sendState == 1
                                  ? Colors.yellowAccent
                                  : Colors.red,
                          size: 16.0,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void newMessage(MessageInterne msg) {
    try{
      ManageNotification.flutterLocalNotificationsPlugin.cancelAll();
      setState(() {
        _messageList.insert(0, msg);
      });
      FlutterRingtonePlayer.play(
        android: AndroidSounds.notification,
        ios: IosSounds.glass,
        volume: 0.1,
        asAlarm: false,
      );
    }catch(e){

    }
  }

}

class ManageNotification {
  static ManageNotification _instance;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  MessageInterne _lastMessage;
  bool _configureIsRunning = false;

  ManageNotification() {
    _instance = this;
    var android = AndroidInitializationSettings('@drawable/logo');
    var ios = IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform,
        onSelectNotification: _executeAction);
  }

  static ManageNotification getInstance() {
    if (_instance == null) ManageNotification();
    return _instance;
  }

  process(Map<String, dynamic> msg, {String from = "onMessage"}) {
    print("process222: $msg");
    //while (_configureIsRunning) {}
    print("process: 1");
    MessageInterne message = MessageInterne.fromMap(msg['data']);
    print("process: 2");
    if(_lastMessage != null && _lastMessage.id == message.id) {
      _configureIsRunning = false;
      return;
    }
    _traiteNotification(message);
    print("process: 3");
    _lastMessage = message;
    _configureIsRunning = false;
    print("process: 4");
  }

  _traiteNotification(MessageInterne message,
      {from = "onMessage"}) async {
    if(GeneralClass.currentUser==null) {
      if(GeneralClass.sharedPreferences==null) GeneralClass.sharedPreferences = await SharedPreferences.getInstance();
      GeneralClass.currentUser=User.myProfileFromSharedPreference();
    }
    if (message.idUserFrom==GeneralClass.currentUser.id) return;
    print("traiteNotification: ${message.id} ${message.username} ${message.creatingTime} ${message.texte}");
    await MessageDAO.getInstance().ajouter(message);
    _showNotification(message);
    try{
      GeneralClass.homePageState.newMessage(message);
    }catch(e){

    }
  }

  _showNotification(MessageInterne message) async {
    String payload = message.id.toString();

    var android = new AndroidNotificationDetails(
        'com.lemendetech.chap_app_wiikko', 'wiikkoo', 'wiikko_chat',
        importance: Importance.Max, priority: Priority.High);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        message.id, message.username, message.texte, platform,
        payload: payload);

  }

  Future<void> _executeAction(String obj) async {
    GeneralClass.homePageState.loadData(onLaunch: true);
    //try{
    //  GeneralClass.homePageState.newMessage(await MessageDAO.getInstance().find(int.parse(obj)));
    //}catch(e){
//
    //}
  }

}
