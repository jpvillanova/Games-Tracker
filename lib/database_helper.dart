import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/user.dart';
import 'models/game.dart';
import 'models/review.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE user(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR NOT NULL,
      email VARCHAR NOT NULL,
      password VARCHAR NOT NULL
    );
    ''');

    await db.execute('''
    CREATE TABLE genre(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR NOT NULL
    );
    ''');

    await db.execute('''
    CREATE TABLE game(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      name VARCHAR NOT NULL UNIQUE,
      description TEXT NOT NULL,
      release_date VARCHAR NOT NULL,
      FOREIGN KEY(user_id) REFERENCES user(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE game_genre(
      game_id INTEGER NOT NULL,
      genre_id INTEGER NOT NULL,
      FOREIGN KEY(game_id) REFERENCES game(id),
      FOREIGN KEY(genre_id) REFERENCES genre(id)
    );
    ''');

    await db.execute('''
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
    ''');
  }

  // CRUD User
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('user', user.toMap());
  }

  Future<User> getUser(int id) async {
    final db = await database;
    var result = await db.query('user', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db
        .update('user', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Game
  Future<int> insertGame(Game game) async {
    final db = await database;
    return await db.insert('game', game.toMap());
  }

  Future<Game> getGame(int id) async {
    final db = await database;
    var result = await db.query('game', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Game.fromMap(result.first) : null;
  }

  Future<int> updateGame(Game game) async {
    final db = await database;
    return await db
        .update('game', game.toMap(), where: 'id = ?', whereArgs: [game.id]);
  }

  Future<int> deleteGame(int id) async {
    final db = await database;
    return await db.delete('game', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Review
  Future<int> insertReview(Review review) async {
    final db = await database;
    return await db.insert('review', review.toMap());
  }

  Future<Review> getReview(int id) async {
    final db = await database;
    var result = await db.query('review', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Review.fromMap(result.first) : null;
  }

  Future<int> updateReview(Review review) async {
    final db = await database;
    return await db.update('review', review.toMap(),
        where: 'id = ?', whereArgs: [review.id]);
  }

  Future<int> deleteReview(int id) async {
    final db = await database;
    return await db.delete('review', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Genre
  Future<int> insertGenre(Genre genre) async {
    final db = await database;
    return await db.insert('genre', genre.toMap());
  }

  Future<Genre> getGenre(int id) async {
    final db = await database;
    var result = await db.query('genre', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Genre.fromMap(result.first) : null;
  }

  Future<int> updateGenre(Genre genre) async {
    final db = await database;
    return await db
        .update('genre', genre.toMap(), where: 'id = ?', whereArgs: [genre.id]);
  }

  Future<int> deleteGenre(int id) async {
    final db = await database;
    return await db.delete('genre', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Genre>> getAllGenres() async {
    final db = await database;
    var result = await db.query('genre');
    List<Genre> genres =
        result.isNotEmpty ? result.map((c) => Genre.fromMap(c)).toList() : [];
    return genres;
  }
}
