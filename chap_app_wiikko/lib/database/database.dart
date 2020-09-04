import 'package:moor_flutter/moor_flutter.dart';

part 'database.g.dart';

class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get texte => text()();

  IntColumn get idUserFrom => integer()();

  TextColumn get username => text()();

  TextColumn get creatingTime => text()();

  IntColumn get sendState => integer().withDefault(Constant(0))();
}

@UseMoor(tables: [Messages])
class AppDatabase extends _$AppDatabase {
  static AppDatabase _instance;

  static AppDatabase getInstance() {
    if (_instance == null) _instance = AppDatabase();
    return _instance;
  }

  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: "db.sqlite", logStatements: true)) {
    _instance = this;
  }

  int get schemaVersion => 1;

  Future insertNewMessage(Message message) => into(messages).insert(message);

  Future<List<Message>> getAllMessage(int _offset) => (select(messages)..orderBy([(t) =>
      OrderingTerm(expression: t.creatingTime, mode: OrderingMode.desc),])..limit(20, offset: _offset)).get();

}
