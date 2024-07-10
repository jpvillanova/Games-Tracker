import 'dart:convert';

class User {
  final int? id;
  final String name; // Changed from username to name
  final String email; // Added email field
  final String password;

  User(
      {this.id,
      required this.name,
      required this.email,
      required this.password}); // Updated constructor

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "name": name, // Changed from username to name
      "email": email, // Added email to map
      "password": password
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map["id"],
        name: map["name"] as String, // Changed from username to name
        email: map["email"] as String, // Added email
        password: map["password"] as String);
  }

  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
