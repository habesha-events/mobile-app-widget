import 'dart:convert';
import 'dart:io';
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
      var response = await _getResponse(city);
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
    final response = await rootBundle.loadString('assets/events_api_response.json');
    Map<String, dynamic> json = jsonDecode(response);
    print("ApiService: loadFakeData $json");
    return ApiResponse(events: json["events"], city:  json["city"], response_type: json["response_type"]);
  }

  Future<http.Response> _getResponse(city) async {
    http.Response? response;
    int retryCount = 0;
    const maxRetries = 3;
    const token = 'yene_secret_qulf_42';

    while (retryCount < maxRetries) {
      try {
        response = await http.get(
          Uri.parse('$baseUrl/events/get?city=$city'),
          headers: {'Authorization': 'Bearer $token',
          },
        );

        print(
            "ApiService: _getResponse: statusCode: ${response.statusCode} body: ${response.body}");
        return response;
      } catch (e, stackTrace) {
        retryCount++;
        print('ApiService: _getResponse: Retry attempt $retryCount failed: $e');
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
        } else {

          print('ApiService: _getResponse: Error type: ${e.runtimeType}');
          print('ApiService: _getResponse: Error message: $e');
          print('ApiService: _getResponse: Stack trace: $stackTrace');

          if (e is SocketException) {
            print('ApiService: _getResponse: OS Error: ${e.osError}'); // Platform-specific error code

            if (e.osError != null) {
              print('ApiService: _getResponse:OS Error Code: ${e.osError!.errorCode}');
              print('ApiService: _getResponse:OS Error Message: ${e.osError!.message}');
            }
          }

          print('ApiService: _getResponse: Failed to get response after $maxRetries retries. Error is $e');
          throw Exception('NO INTERNET $e $stackTrace');
        }
      }
    }
    throw Exception('ApiService: _getResponse: This should never happen');
  }
}
