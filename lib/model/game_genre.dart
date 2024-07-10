class GameGenre {
  final int gameId;
  final int genreId;

  GameGenre({
    required this.gameId,
    required this.genreId,
  });

  Map<String, dynamic> toMap() {
    return {
      'game_id': gameId,
      'genre_id': genreId,
    };
  }

  factory GameGenre.fromMap(Map<String, dynamic> map) {
    return GameGenre(
      gameId: map['game_id'] as int,
      genreId: map['genre_id'] as int,
    );
  }
}
