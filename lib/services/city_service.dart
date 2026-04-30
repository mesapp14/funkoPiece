import 'dart:convert';
import 'package:http/http.dart' as http;

class CityService {
  Future<List<dynamic>> search(String query) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5",
    );

    final res = await http.get(url, headers: {
      "User-Agent": "PiratePopApp/1.0"
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }
}