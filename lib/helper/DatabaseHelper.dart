import 'package:sqflite/sqflite.dart'; // Ensure this import is correctly placed at the top of your file
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import "../model/user.dart";

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  static Database? _db;

  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  Future<Database> get db async {
    return _db ??= await initDb();
  }

  Future<Database> initDb() async {
    final io.Directory appDocumentsDir =
        await getApplicationDocumentsDirectory();
    String path = p.join(appDocumentsDir.path, "login.db");
    print("Database Path: $path");

    Database db =
        await openDatabase(path, version: 1, onCreate: (db, version) async {
      String sql = """
        CREATE TABLE user( 
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          username VARCHAR, 
          password VARCHAR
        );""";
      await db.execute(sql);
    });

    return db;
  }
}
