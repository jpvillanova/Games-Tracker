import 'package:login_app/helper/database_helper.dart';
import '../model/game.dart';

class GameController {
  DatabaseHelper con = DatabaseHelper();

  Future<int> createGame(Game game) async {
    var db = await con.db;
    int res = await db.insert('game', game.toMap());
    return res;
  }

  Future<int> deleteGame(Game game) async {
    var db = await con.db;
    int res = await db.delete("game", where: "id = ?", whereArgs: [game.id]);
    return res;
  }

  Future<int> editGame(Game game) async {
    var db = await con.db;
    int res = await db
        .update('game', game.toMap(), where: 'id = ?', whereArgs: [game.id]);
    return res;
  }

  Future<List<Game>> getAllGames() async {
    var db = await con.db;
    var res = await db.query("game");
    List<Game> list =
        res.isNotEmpty ? res.map((c) => Game.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Game>> getFilteredGames(
      {String? releaseDate, int? genreId, double? averageScore}) async {
    if (genreId == -1) {
      return [];
    }

    var db = await con.db;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    String sql = '''
      SELECT g.*, IFNULL(AVG(r.score), 0) AS average_score
      FROM game g
      LEFT JOIN review r ON g.id = r.game_id
    ''';

    if (releaseDate != null) {
      whereClauses.add('g.release_date = ?');
      whereArgs.add(releaseDate);
    }
    if (genreId != null) {
      whereClauses
          .add('g.id IN (SELECT game_id FROM game_genre WHERE genre_id = ?)');
      whereArgs.add(genreId);
    }
    if (averageScore != null) {
      whereClauses.add('g.average_score = ?');
      whereArgs.add(averageScore);
    }

    if (whereClauses.isNotEmpty) {
      sql += ' WHERE ${whereClauses.join(' AND ')}';
    }

    sql += ' GROUP BY g.id';

    final List<Map<String, dynamic>> result = await db.rawQuery(sql, whereArgs);

    List<Game> games = result.map((gameMap) => Game.fromMap(gameMap)).toList();
    return games;
  }

  Future<List<Game>> getUserGames(int userId) async {
    var db = await con.db;
    var res = await db.query("game", where: "user_id = ?", whereArgs: [userId]);
    List<Game> list =
        res.isNotEmpty ? res.map((c) => Game.fromMap(c)).toList() : [];
    return list;
  }
}
