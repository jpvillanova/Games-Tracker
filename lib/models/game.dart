class Game {
  int id;
  int userId;
  String name;
  String description;
  String releaseDate;

  Game({this.id, this.userId, this.name, this.description, this.releaseDate});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'release_date': releaseDate,
    };
  }

  Game.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    userId = map['user_id'];
    name = map['name'];
    description = map['description'];
    releaseDate = map['release_date'];
  }
}
