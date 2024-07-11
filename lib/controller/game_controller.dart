import 'package:login_app/helper/database_helper.dart';
import '../model/game.dart';

class GameController {
  DatabaseHelper con = DatabaseHelper();

  Future<int> createGame(Game game) async {
    // Renamed from saveGame to createGame
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
      {String? releaseDate, int? genreId, double? minScore}) async {
    var db = await con.db;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    String sql = '''
      SELECT g.*, IFNULL(AVG(r.score), 0) AS average_score
      FROM game g
      LEFT JOIN review r ON g.id = r.game_id
    ''';

    // Adicione condições conforme necessário e verifique os valores
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

    sql += ' GROUP BY g.id';

    final List<Map<String, dynamic>> result = await db.rawQuery(sql, whereArgs);
    List<Game> games = result.map((gameMap) => Game.fromMap(gameMap)).toList();
    print('AAAAAAAAAAAAAAAAAAA');
    print(
        "Fetched games: ${games.length}"); // Depuração para verificar a contagem de jogos
    return games;
  }
}
