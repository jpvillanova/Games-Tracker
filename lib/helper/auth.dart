import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  static Future<void> signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt("value", 0);
  }
}
