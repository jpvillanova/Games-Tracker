import 'package:login_app/helper/database_helper.dart';
import '../model/review.dart';

class ReviewController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> addReview(Review review) async {
    var db = await _dbHelper.db;
    try {
      int result = await db.insert('review', review.toMap());
      if (result != -1) {
        // Atualiza a pontuação média do jogo
        await _updateGameAverageScore(review.gameId);
      }
      return result;
    } catch (e) {
      print('Error adding review: $e');
      return -1;
    }
  }

  Future<void> _updateGameAverageScore(int gameId) async {
    var db = await _dbHelper.db;

    var avgQuery = await db.rawQuery('''
      SELECT AVG(score) as average_score
      FROM review
      WHERE game_id = ?
    ''', [gameId]);
    double newAverageScore =
        (avgQuery.first['average_score'] as num).toDouble();

    // Imprime o novo average score calculado
    print('New average score for game ID $gameId: $newAverageScore');

    await db.update('game', {'average_score': newAverageScore},
        where: 'id = ?', whereArgs: [gameId]);
  }

  Future<List<Review>> fetchReviewsByGameId(int gameId) async {
    var db = await _dbHelper.db;
    List<Map<String, dynamic>> maps = await db.query(
      'review',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
    return List.generate(maps.length, (i) {
      return Review.fromMap(maps[i]);
    });
  }
}
