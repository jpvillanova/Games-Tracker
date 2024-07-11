class Game {
  final int? id;
  final int userId;
  String name;
  String releaseDate;
  String description;
  final double averageScore;

  Game({
    this.id,
    required this.userId,
    required this.name,
    required this.releaseDate,
    required this.description,
    required this.averageScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'release_date': releaseDate,
      'description': description,
      'average_score': averageScore,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      releaseDate: map['release_date'] as String,
      description: map['description'] as String,
      averageScore: (map['average_score'] as num).toDouble(),
    );
  }
}
