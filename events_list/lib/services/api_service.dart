import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://18.221.37.124';
  static const bool useFakeData = kDebugMode && false;

  Future<List<dynamic>> getEvents(String city) async {
    print("ApiService: getEvents: useFakeData $useFakeData city ${city}");
    if (useFakeData) {
      return _loadFakeData();
    } else {
      final response = await http.get(Uri.parse('$baseUrl/event/get?location=wa--seattle'));
      print("ApiService: statusCode ${response.statusCode} ${response.body}");
      if (response.statusCode == 200) {
        var result = [];
        try{
          Map<String, dynamic> parsedMap = jsonDecode(response.body.toString());
          result = parsedMap["location"];
        }catch(e){
          throw Exception('ApiService: Failed to load events: parsing error: $e');
        }
        return result;
      } else {
        throw Exception('ApiService: Failed to load events');
      }
    }
  }

  Future<List<dynamic>> _loadFakeData() async {
    print("ApiService: loadFakeData");
    final response = await rootBundle.loadString('assets/events_api_response.json');
    return json.decode(response);
  }
}
