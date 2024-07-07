import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://your-api-url.com';
  static const bool useFakeData = true;

  Future<List<dynamic>> getEvents(String city) async {
    if (useFakeData) {
      return _loadFakeData();
    } else {
      final response = await http.get(Uri.parse('\$baseUrl/get_events?location_city=\$city'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load events');
      }
    }
  }

  Future<List<dynamic>> _loadFakeData() async {
    final response = await rootBundle.loadString('assets/events_api_response.json');
    print("_loadFakeData: jsonResponse: $response");
    return json.decode(response);
  }
}
