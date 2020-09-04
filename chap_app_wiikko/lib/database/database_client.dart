import 'dart:async';
import 'dart:io';

import 'package:chap_app_wiikko/models/message.dart';
import 'package:chap_app_wiikko/models/message_dao.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseClient {
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _create();
      return _database;
    }
  }

  Future _create() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String databaseDirectory = join(directory.path, 'dedb1.db');
    var bdd =
        await openDatabase(databaseDirectory, version: 1, onCreate: _onCreate);
    return bdd;
  }

  Future _onCreate(Database db, version) async {
    await db.execute(MessageDAO.TABLE_CREATE);
  }
}
