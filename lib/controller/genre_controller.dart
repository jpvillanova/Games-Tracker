import 'package:login_app/helper/database_helper.dart';
import 'package:login_app/model/game_genre.dart';
import 'package:login_app/model/genre.dart';

class GenreController {
  DatabaseHelper con = DatabaseHelper();

  Future<int> updateGameGenreAssociation(int gameId, int newGenreId) async {
    var db = await con.db;
    int result = await db.update(
        'game_genre', {'genre_id': newGenreId}, // Atualiza apenas o genre_id
        where: 'game_id = ?',
        whereArgs: [gameId]); // Filtra apenas pelo game_id
    print('Resultado da atualização: $result');
    return result;
  }

  Future<void> createGameGenreAssociation(int gameId, int genreId) async {
    var db = await con.db;
    GameGenre gameGenre = GameGenre(gameId: gameId, genreId: genreId);
    await db.insert('game_genre', gameGenre.toMap());
  }

  Future<int> createGenre(Genre genre) async {
    var db = await con.db;
    int res = await db.insert('genre', genre.toMap());
    return res;
  }

  Future<int> getOrCreateGenreId(String genreName) async {
    var db = await con.db;
    List<Map> maps = await db.query('genre',
        columns: ['id'], where: 'name = ?', whereArgs: [genreName]);

    if (maps.isNotEmpty) {
      return maps.first['id']; // Returns the existing ID
    } else {
      // Creates a new genre and returns the ID
      int newId = await createGenre(Genre(name: genreName));
      return newId;
    }
  }

  Future<int> getGenreId(String genreName) async {
    var db = await con.db;
    List<Map> maps = await db.query('genre',
        columns: ['id'], where: 'name = ?', whereArgs: [genreName]);

    if (maps.isNotEmpty) {
      return maps.first['id'] as int; // Returns the existing ID if not null
    } else {
      return -1;
    }
  }

  Future<void> updateGenre(int id, String newName) async {
    var db = await con.db;
    await db.update('genre', {'name': newName},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getGenreNameByGameId(int gameId) async {
    var db = await con.db;
    var result = await db.rawQuery('''
      SELECT g.name FROM genre g
      JOIN game_genre gg ON g.id = gg.genre_id
      WHERE gg.game_id = ?
    ''', [gameId]);

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return null;
  }

  Future<List<Genre>> getGenres() async {
    var db = await con.db;
    List<Map> maps = await db.query('genre');
    return List.generate(maps.length, (i) {
      return Genre.fromMap(maps[i] as Map<String, dynamic>);
    });
  }
}
