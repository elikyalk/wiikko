import 'package:chap_app_wiikko/database/database_client.dart';
import 'package:chap_app_wiikko/models/message.dart';
import 'package:sqflite/sqflite.dart';

class MessageDAO extends DatabaseClient {
  static final String KEY = "id";
  static final String TEXTE = "texte";
  static final String ID_USER_FROM = "idUserFrom";
  static final String USERNAME = "username";
  static final String CREATING_TIME = "creatingTime";
  static final String SEND_STATE = "sendState";
  static final String TABLE_NOM = "t_message";
  static final String TABLE_CREATE = "CREATE TABLE " +
      TABLE_NOM +
      " (" +
      KEY +
      " INTEGER PRIMARY KEY, " +
      TEXTE +
      " TEXT, " +
      ID_USER_FROM +
      " INTEGER, " +
      USERNAME +
      " TEXT, " +
      CREATING_TIME +
      " TEXT, " +
      SEND_STATE +
      " INTEGER);";

  // ignore: non_constant_identifier_names
  static final TABLE_DROP = "DROP TABLE IF EXISTS " + TABLE_NOM + ";";

  static MessageDAO instance;
  Database _database;

  MessageDAO() {
    instance = this;
  }

  static MessageDAO getInstance() {
    if (instance == null) new MessageDAO();
    return instance;
  }

  Future<int> count() async {
    _database = await database;
    String sql = "SELECT COUNT(*) as compteur FROM " + TABLE_NOM;
    int co = 0;
    try {
      List<Map<String, dynamic>> resultat = await _database.rawQuery(sql);
      resultat.forEach((map) {
        co = map["compteur"];
      });
    } catch (e) {}
    return co;
  }

  Future<MessageInterne> ajouter(MessageInterne obj) async {
    _database = await database;

    MessageInterne response;
    try {
      if (await find(obj.id) == null) {
        int retour = await _database.insert(TABLE_NOM, obj.toMap());
        response = await find(retour);
      } else {
        await modifier(obj);
        response = await find(obj.id);
      }
    } catch (e) {

    }
    return response;
  }

  Future<MessageInterne> find(int id) async {
    _database = await database;
    MessageInterne object;
    String sql = "SELECT * FROM " + TABLE_NOM + " WHERE " + KEY + " = $id";
    try {
      List<Map<String, dynamic>> resultat = await _database.rawQuery(sql);
      for (int i = 0; i < resultat.length; i++) {
        Map<String, dynamic> map = resultat[i];
        object = MessageInterne.fromMap(map);
      }
    } catch (e) {}
    return object;
  }

  Future<List<MessageInterne>> findAll(int offset) async {
    _database = await database;
    List<MessageInterne> list = [];
    String sql = "select * from $TABLE_NOM order by $CREATING_TIME desc limit $offset, 20";
    try {
      List<Map<String, dynamic>> resultat = await _database.rawQuery(sql);
      for (int i = 0; i < resultat.length; i++) {
        Map<String, dynamic> map = resultat[i];
        MessageInterne object = MessageInterne.fromMap(map);
        list.add(object);
      }
    } catch (e) {

    }
    return list;
  }

  Future<int> modifier(MessageInterne obj) async {
    _database = await database;
    int rep = await _database.update(TABLE_NOM, obj.toMap(),
        where: KEY + "= ?", whereArgs: [obj.id]);
    print("Event update : $rep; content: ${obj.toMap()}");
    return rep;
  }

  Future<bool> supprimer(int id) async {
    _database = await database;
    int rep =
        await _database.delete(TABLE_NOM, where: KEY + " = ?", whereArgs: [id]);
    if (rep > 0) return true;
    return false;
  }

  Future<bool> supprimerTout() async {
    _database = await database;
    int rep = await _database.delete(TABLE_NOM);
    if (rep > 0) return true;
    return false;
  }
}
