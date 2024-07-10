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
}
