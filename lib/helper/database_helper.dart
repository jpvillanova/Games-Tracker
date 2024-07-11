import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

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
    String path = p.join(appDocumentsDir.path, "games_tracker.db");
    print("Database Path: $path");

    Database db = await openDatabase(path, version: 1, onCreate: _createDb);
    return db;
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute("""
      CREATE TABLE user( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name VARCHAR, 
        email VARCHAR,
        password VARCHAR
      );
    """);
    await db.execute("""
      CREATE TABLE genre(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL
      );
    """);
    await db.execute("""
      CREATE TABLE game(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name VARCHAR NOT NULL UNIQUE,
        description TEXT NOT NULL,
        release_date VARCHAR NOT NULL,
        average_score REAL NOT NULL,
        FOREIGN KEY(user_id) REFERENCES user(id)
      );
    """);
    await db.execute("""
      CREATE TABLE game_genre(
        game_id INTEGER NOT NULL,
        genre_id INTEGER NOT NULL,
        FOREIGN KEY(game_id) REFERENCES game(id),
        FOREIGN KEY(genre_id) REFERENCES genre(id)
      );
    """);
    await db.execute("""
      CREATE TABLE review(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        game_id INTEGER NOT NULL,
        score REAL NOT NULL,
        description TEXT NOT NULL,
        date VARCHAR NOT NULL,
        FOREIGN KEY(user_id) REFERENCES user(id),
        FOREIGN KEY(game_id) REFERENCES game(id)
      );
    """);
  }
}
