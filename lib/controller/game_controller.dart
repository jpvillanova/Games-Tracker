import 'package:login_app/helper/database_helper.dart';
import '../model/game.dart';

class GameController {
  DatabaseHelper con = DatabaseHelper();

  Future<int> saveGame(Game game) async {
    var db = await con.db;
    int res = await db.insert('game', game.toMap());
    return res;
  }

  Future<int> deleteGame(Game game) async {
    var db = await con.db;
    int res = await db.delete("game", where: "id = ?", whereArgs: [game.id]);
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
      {String? releaseDate, int? genreId, double? minScore}) async {
    var db = await con.db;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    String sql = '''
      SELECT g.id, g.name, IFNULL(AVG(r.score), 0) AS average_score
      FROM games g
      LEFT JOIN reviews r ON g.id = r.game_id
    ''';

    if (releaseDate != null) {
      whereClauses.add('g.release_date = ?');
      whereArgs.add(releaseDate);
    }
    if (genreId != null) {
      whereClauses.add('g.genre_id = ?');
      whereArgs.add(genreId);
    }
    if (minScore != null) {
      whereClauses.add('r.score >= ?');
      whereArgs.add(minScore);
    }

    if (whereClauses.isNotEmpty) {
      sql += ' WHERE ${whereClauses.join(' AND ')}';
    }

    sql += ' GROUP BY g.id, g.name';

    final List<Map<String, dynamic>> result = await db.rawQuery(sql, whereArgs);
    return result.map((gameMap) => Game.fromMap(gameMap)).toList();
  }
}
