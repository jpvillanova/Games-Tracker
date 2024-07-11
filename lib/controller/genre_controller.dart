import 'package:login_app/helper/database_helper.dart';
import 'package:login_app/model/game_genre.dart';
import 'package:login_app/model/genre.dart';

class GenreController {
  DatabaseHelper con = DatabaseHelper();

  Future<int> createOrUpdateGameGenre(GameGenre gameGenre) async {
    var db = await con.db;
    // Check if the game_genre association already exists
    List<Map> existing = await db.query('game_genre',
        where: 'game_id = ? AND genre_id = ?',
        whereArgs: [gameGenre.gameId, gameGenre.genreId]);

    if (existing.isNotEmpty) {
      // Update existing game_genre association
      return await db.update('game_genre', gameGenre.toMap(),
          where: 'game_id = ? AND genre_id = ?',
          whereArgs: [gameGenre.gameId, gameGenre.genreId]);
    } else {
      // Create new game_genre association
      return await db.insert('game_genre', gameGenre.toMap());
    }
  }

  Future<void> createOrUpdateGameGenreAssociation(
      int gameId, int genreId) async {
    GameGenre gameGenre = GameGenre(gameId: gameId, genreId: genreId);
    await createOrUpdateGameGenre(gameGenre);
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
