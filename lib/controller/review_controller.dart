import 'package:intl/intl.dart';
import 'package:login_app/helper/database_helper.dart';
import '../model/review.dart';

class ReviewController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> addReview(Review review) async {
    var db = await _dbHelper.db;
    try {
      int result = await db.insert('review', review.toMap());
      if (result != -1) {
        await _updateGameAverageScore(review.gameId);
      }
      return result;
    } catch (e) {
      print('Erro ao adicionar o review: $e');
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

    newAverageScore = double.parse(newAverageScore.toStringAsFixed(1));

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

  Future<List<Review>> fetchRecentReviewsByGameId(int gameId, int days) async {
    var db = await _dbHelper.db;
    var now = DateTime.now();
    var sevenDaysAgo = now.subtract(Duration(days: days));
    List<Map<String, dynamic>> maps = await db.query(
      'review',
      where: 'game_id = ? AND date >= ?',
      whereArgs: [gameId, DateFormat('yyyy-MM-dd').format(sevenDaysAgo)],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return Review.fromMap(maps[i]);
    });
  }
}
