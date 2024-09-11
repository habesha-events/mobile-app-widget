import 'dart:convert';
import 'package:events_app/models/api_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'location_service.dart';

class ApiService {
  static const String baseUrl = 'http://18.221.37.124';
  static const bool useFakeData = kDebugMode && false;

  Future<ApiResponse> getEvents(String city) async {
    print("ApiService: getEvents: useFakeData=$useFakeData, city=${city}");
    if (useFakeData) {
      return _loadFakeData();
    } else {
      var response;
      try{
         response = await http.get(Uri.parse('$baseUrl/events/get?city=$city'));
        print("ApiService: statusCode: ${response.statusCode} body: ${response.body}");
      }catch(e){
        throw Exception('NO INTERNET $e');
      }
      if (response.statusCode == 200) {
        var events = [];
        var city = "";
        var response_type = "";

        try{
          Map<String, dynamic> json = jsonDecode(response.body.toString());
          events = json["events"];
          city = json["city"];
          response_type = json["response_type"];
        }catch(e){
          throw Exception('Failed to load events: parsing error: $e');
        }

        return ApiResponse(events: events, city: city, response_type: response_type);
      } else {
        throw Exception('Failed to load events: statusCode: ${response.statusCode}');
      }
    }
  }

  Future<ApiResponse> _loadFakeData() async {
    print("ApiService: loadFakeData");
    final response = await rootBundle.loadString('assets/events_api_response.json');
    Map<String, dynamic> json = jsonDecode(response);
    return ApiResponse(events: json["events"], city:  json["city"], response_type: json["response_type"]);
  }
}
