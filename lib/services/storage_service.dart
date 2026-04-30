import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<void> saveToken(String token, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt_token", token);
    await prefs.setBool("remember_me", rememberMe);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}