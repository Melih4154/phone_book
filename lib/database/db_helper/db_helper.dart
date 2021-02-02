import 'dart:async';

import 'package:phone_book/model/contact.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();

    return _db;
  }

  initDb() async {
    var dbFolder = await getDatabasesPath();
    String path = join(dbFolder, 'Contact.db');

    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  Future<FutureOr<void>> _onCreate(Database db, int version) async {
    await db.execute(
        'Create Table Contact(id Integer Primary Key, name Text, phoneNumber Text, avatar Text)');
  }

  Future<List<void>> getContact() async {
    var dbClient = await db;

    var result = await dbClient.query('Contact', orderBy: 'name');
    return result.map((e) => Contact.fromMap(e)).toList();
  }

  Future<int> contactAdd(Contact contact) async {
    var dbClient = await db;
    return await dbClient.insert('Contact', contact.toMap());
  }

  Future<void> removeAt(int id) async {
    var dbClient = await db;
    return await dbClient.delete('Contact', where: "id=?", whereArgs: [id]);
  }
}
