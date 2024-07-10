class Review {
  final int? id;
  final int userId;
  final int gameId;
  final double score;
  final String description;
  final String date;

  Review({
    this.id,
    required this.userId,
    required this.gameId,
    required this.score,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'game_id': gameId,
      'score': score,
      'description': description,
      'date': date,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      gameId: map['game_id'] as int,
      score: map['score'] as double,
      description: map['description'] as String,
      date: map['date'] as String,
    );
  }
}
