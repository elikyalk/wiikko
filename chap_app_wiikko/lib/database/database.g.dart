// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Message extends DataClass implements Insertable<Message> {
  final int id;
  final String texte;
  final int idUserFrom;
  final String username;
  final String creatingTime;
  final int sendState;
  Message(
      {@required this.id,
      @required this.texte,
      @required this.idUserFrom,
      @required this.username,
      @required this.creatingTime,
      @required this.sendState});
  factory Message.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Message(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      texte:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}texte']),
      idUserFrom: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}id_user_from']),
      username: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}username']),
      creatingTime: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}creating_time']),
      sendState:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}send_state']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || texte != null) {
      map['texte'] = Variable<String>(texte);
    }
    if (!nullToAbsent || idUserFrom != null) {
      map['id_user_from'] = Variable<int>(idUserFrom);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || creatingTime != null) {
      map['creating_time'] = Variable<String>(creatingTime);
    }
    if (!nullToAbsent || sendState != null) {
      map['send_state'] = Variable<int>(sendState);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      texte:
          texte == null && nullToAbsent ? const Value.absent() : Value(texte),
      idUserFrom: idUserFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(idUserFrom),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      creatingTime: creatingTime == null && nullToAbsent
          ? const Value.absent()
          : Value(creatingTime),
      sendState: sendState == null && nullToAbsent
          ? const Value.absent()
          : Value(sendState),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      texte: serializer.fromJson<String>(json['texte']),
      idUserFrom: serializer.fromJson<int>(json['idUserFrom']),
      username: serializer.fromJson<String>(json['username']),
      creatingTime: serializer.fromJson<String>(json['creatingTime']),
      sendState: serializer.fromJson<int>(json['sendState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'texte': serializer.toJson<String>(texte),
      'idUserFrom': serializer.toJson<int>(idUserFrom),
      'username': serializer.toJson<String>(username),
      'creatingTime': serializer.toJson<String>(creatingTime),
      'sendState': serializer.toJson<int>(sendState),
    };
  }

  Message copyWith(
          {int id,
          String texte,
          int idUserFrom,
          String username,
          String creatingTime,
          int sendState}) =>
      Message(
        id: id ?? this.id,
        texte: texte ?? this.texte,
        idUserFrom: idUserFrom ?? this.idUserFrom,
        username: username ?? this.username,
        creatingTime: creatingTime ?? this.creatingTime,
        sendState: sendState ?? this.sendState,
      );
  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('texte: $texte, ')
          ..write('idUserFrom: $idUserFrom, ')
          ..write('username: $username, ')
          ..write('creatingTime: $creatingTime, ')
          ..write('sendState: $sendState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          texte.hashCode,
          $mrjc(
              idUserFrom.hashCode,
              $mrjc(username.hashCode,
                  $mrjc(creatingTime.hashCode, sendState.hashCode))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.texte == this.texte &&
          other.idUserFrom == this.idUserFrom &&
          other.username == this.username &&
          other.creatingTime == this.creatingTime &&
          other.sendState == this.sendState);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<String> texte;
  final Value<int> idUserFrom;
  final Value<String> username;
  final Value<String> creatingTime;
  final Value<int> sendState;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.texte = const Value.absent(),
    this.idUserFrom = const Value.absent(),
    this.username = const Value.absent(),
    this.creatingTime = const Value.absent(),
    this.sendState = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    @required String texte,
    @required int idUserFrom,
    @required String username,
    @required String creatingTime,
    @required int sendState,
  })  : texte = Value(texte),
        idUserFrom = Value(idUserFrom),
        username = Value(username),
        creatingTime = Value(creatingTime),
        sendState = Value(sendState);
  static Insertable<Message> custom({
    Expression<int> id,
    Expression<String> texte,
    Expression<int> idUserFrom,
    Expression<String> username,
    Expression<String> creatingTime,
    Expression<int> sendState,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (texte != null) 'texte': texte,
      if (idUserFrom != null) 'id_user_from': idUserFrom,
      if (username != null) 'username': username,
      if (creatingTime != null) 'creating_time': creatingTime,
      if (sendState != null) 'send_state': sendState,
    });
  }

  MessagesCompanion copyWith(
      {Value<int> id,
      Value<String> texte,
      Value<int> idUserFrom,
      Value<String> username,
      Value<String> creatingTime,
      Value<int> sendState}) {
    return MessagesCompanion(
      id: id ?? this.id,
      texte: texte ?? this.texte,
      idUserFrom: idUserFrom ?? this.idUserFrom,
      username: username ?? this.username,
      creatingTime: creatingTime ?? this.creatingTime,
      sendState: sendState ?? this.sendState,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (texte.present) {
      map['texte'] = Variable<String>(texte.value);
    }
    if (idUserFrom.present) {
      map['id_user_from'] = Variable<int>(idUserFrom.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (creatingTime.present) {
      map['creating_time'] = Variable<String>(creatingTime.value);
    }
    if (sendState.present) {
      map['send_state'] = Variable<int>(sendState.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('texte: $texte, ')
          ..write('idUserFrom: $idUserFrom, ')
          ..write('username: $username, ')
          ..write('creatingTime: $creatingTime, ')
          ..write('sendState: $sendState')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  final GeneratedDatabase _db;
  final String _alias;
  $MessagesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _texteMeta = const VerificationMeta('texte');
  GeneratedTextColumn _texte;
  @override
  GeneratedTextColumn get texte => _texte ??= _constructTexte();
  GeneratedTextColumn _constructTexte() {
    return GeneratedTextColumn(
      'texte',
      $tableName,
      false,
    );
  }

  final VerificationMeta _idUserFromMeta = const VerificationMeta('idUserFrom');
  GeneratedIntColumn _idUserFrom;
  @override
  GeneratedIntColumn get idUserFrom => _idUserFrom ??= _constructIdUserFrom();
  GeneratedIntColumn _constructIdUserFrom() {
    return GeneratedIntColumn(
      'id_user_from',
      $tableName,
      false,
    );
  }

  final VerificationMeta _usernameMeta = const VerificationMeta('username');
  GeneratedTextColumn _username;
  @override
  GeneratedTextColumn get username => _username ??= _constructUsername();
  GeneratedTextColumn _constructUsername() {
    return GeneratedTextColumn(
      'username',
      $tableName,
      false,
    );
  }

  final VerificationMeta _creatingTimeMeta =
      const VerificationMeta('creatingTime');
  GeneratedTextColumn _creatingTime;
  @override
  GeneratedTextColumn get creatingTime =>
      _creatingTime ??= _constructCreatingTime();
  GeneratedTextColumn _constructCreatingTime() {
    return GeneratedTextColumn(
      'creating_time',
      $tableName,
      false,
    );
  }

  final VerificationMeta _sendStateMeta = const VerificationMeta('sendState');
  GeneratedIntColumn _sendState;
  @override
  GeneratedIntColumn get sendState => _sendState ??= _constructSendState();
  GeneratedIntColumn _constructSendState() {
    return GeneratedIntColumn(
      'send_state',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [id, texte, idUserFrom, username, creatingTime, sendState];
  @override
  $MessagesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'messages';
  @override
  final String actualTableName = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('texte')) {
      context.handle(
          _texteMeta, texte.isAcceptableOrUnknown(data['texte'], _texteMeta));
    } else if (isInserting) {
      context.missing(_texteMeta);
    }
    if (data.containsKey('id_user_from')) {
      context.handle(
          _idUserFromMeta,
          idUserFrom.isAcceptableOrUnknown(
              data['id_user_from'], _idUserFromMeta));
    } else if (isInserting) {
      context.missing(_idUserFromMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username'], _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('creating_time')) {
      context.handle(
          _creatingTimeMeta,
          creatingTime.isAcceptableOrUnknown(
              data['creating_time'], _creatingTimeMeta));
    } else if (isInserting) {
      context.missing(_creatingTimeMeta);
    }
    if (data.containsKey('send_state')) {
      context.handle(_sendStateMeta,
          sendState.isAcceptableOrUnknown(data['send_state'], _sendStateMeta));
    } else if (isInserting) {
      context.missing(_sendStateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Message.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(_db, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $MessagesTable _messages;
  $MessagesTable get messages => _messages ??= $MessagesTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [messages];
}
