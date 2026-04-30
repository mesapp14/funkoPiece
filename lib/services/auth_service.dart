import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final Map<String, dynamic>? raw;

  AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.raw,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json["status"] == "success",
      message: json["message"],
      token: json["token"],
      raw: json,
    );
  }
}

class AuthService {
  static const String baseUrl = "https://alienbash.com/backend/auth";

  Future<AuthResponse> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    return AuthResponse.fromJson(jsonDecode(res.body));
  }

  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String pirateName,
    required String city,
    double? lat,
    double? lon,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/signup.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "pirate_name": pirateName,
        "city_name": city,
        "latitude": lat,
        "longitude": lon,
      }),
    );

    return AuthResponse.fromJson(jsonDecode(res.body));
  }

  Future<AuthResponse> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/forgot.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return AuthResponse.fromJson(jsonDecode(res.body));
  }
}