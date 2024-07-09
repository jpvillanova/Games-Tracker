class Genre {
  int id;
  String name;

  Genre({this.id, this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  Genre.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
  }
}
