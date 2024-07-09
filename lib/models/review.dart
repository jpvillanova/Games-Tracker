class Review {
  int id;
  int userId;
  int gameId;
  double score;
  String description;
  String date;

  Review(
      {this.id,
      this.userId,
      this.gameId,
      this.score,
      this.description,
      this.date});

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

  Review.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    userId = map['user_id'];
    gameId = map['game_id'];
    score = map['score'];
    description = map['description'];
    date = map['date'];
  }
}
