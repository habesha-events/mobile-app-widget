import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'location_service.dart';

class ApiService {
  static const String BASE_URL = 'http://18.221.37.124';
  static const String TOKEN = 'yene_secret_qulf_42';
  static const bool USE_LOCAL_JSON_API = true;

  //returns jsonList
  Future<List<dynamic>> getEvents(String city) async {
    print("ApiService: getEvents: useFakeData=$USE_LOCAL_JSON_API, city=${city}");
    if (USE_LOCAL_JSON_API) {
      return _loadEventsLocalJsonApiResponse();
    } else {
      var response = await _getApiResponse('$BASE_URL/events/get_2?city=$city');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = [];

        try{
          jsonList = jsonDecode(response.body.toString());
        }catch(e){
          throw Exception('ApiService: getEvents: Failed to load events: parsing error: $e');
        }

        return jsonList;
      } else {
        throw Exception('ApiService: getEvents: Failed to load events: statusCode: ${response.statusCode}');
      }
    }
  }

  //returns jsonList
  Future<List<dynamic>?> getSupportedCitiesFromApi() async {
    if (USE_LOCAL_JSON_API) {
      return loadSupportedCitiesLocalJsonApiResponse();
    }else{
      var response = await _getApiResponse('$BASE_URL/cities/supported');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = [];

        try{
          jsonList = jsonDecode(response.body.toString());
        }catch(e){
          throw Exception('ApiService: getSupportedCitiesFromApi: parsing error: $e');
        }

        return jsonList;
      } else {
        print('ApiService: getSupportedCitiesFromApi: Failed to SupportedCities: statusCode: ${response.statusCode}: returning SUPPORTED_CITIES_DEFAULT');
        return null;
      }
    }

  }


    Future<http.Response> _getApiResponse(fullUrl) async {
    http.Response? response;
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        response = await http.get(
          Uri.parse(fullUrl),
          headers: {'Authorization': 'Bearer $TOKEN',
          },
        );

        print(
            "ApiService: _getApiResponse: statusCode: ${response.statusCode} body: ${response.body}");
        return response;
      } catch (e, stackTrace) {
        retryCount++;
        print('ApiService: _getApiResponse: Retry attempt $retryCount failed: $e');
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
        } else {

          print('ApiService: _getApiResponse: Error type: ${e.runtimeType}');
          print('ApiService: _getApiResponse: Error message: $e');
          print('ApiService: _getApiResponse: Stack trace: $stackTrace');

          if (e is SocketException) {
            print('ApiService: _getApiResponse: OS Error: ${e.osError}'); // Platform-specific error code

            if (e.osError != null) {
              print('ApiService: _getApiResponse:OS Error Code: ${e.osError!.errorCode}');
              print('ApiService: _getApiResponse:OS Error Message: ${e.osError!.message}');
            }
          }

          print('ApiService: _getApiResponse: Failed to get response after $maxRetries retries. Error is $e');
          throw Exception('NO INTERNET $e $stackTrace');
        }
      }
    }
    throw Exception('ApiService: _getApiResponse: This should never happen');
  }


  Future<List<dynamic>> _loadEventsLocalJsonApiResponse() async {
    final response = await rootBundle.loadString('assets/events_api_response.json');
    List<dynamic> jsonList = jsonDecode(response);
    print("ApiService: _loadFakeEventsResponse $jsonList");
    return jsonList;
  }

  Future<List<dynamic>> loadSupportedCitiesLocalJsonApiResponse() async {
    final response = await rootBundle.loadString('assets/supported_cities_api_response.json');
    List<dynamic> jsonList = jsonDecode(response);
    print("ApiService: _loadFakeSupportedCitiesResponse $json");
    return jsonList;
  }
}
