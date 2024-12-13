import 'dart:async';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl =
      'https://6703907dab8a8f892730a6d2.mockapi.io/api/v1/memorycardgame';

  Future<Map<String, dynamic>?> fetchIsOn() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data[0];
        }
      }
    // ignore: empty_catches
    } catch (e) {
    }
    return null;
  }

  Future<bool> isValidUrl(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !['http', 'https'].contains(uri.scheme)) {
        return false;
      }

      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
