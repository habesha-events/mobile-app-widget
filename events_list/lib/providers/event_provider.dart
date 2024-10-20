import 'package:events_app/models/api_response.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/location_service.dart';

class EventProvider with ChangeNotifier {
  ApiResponse get localResponse => _localResponse;
  ApiResponse _localResponse = ApiResponse(events: []);

  String get inputCity => _inputCity;
  String _inputCity = "";

  bool get loading => _loading;
  bool _loading = false;

  bool get isError => _isError;
  bool _isError = false;

  String get errorMessage => _errorMessage;
  String _errorMessage = "";


  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();
  final LocationService _locationService = LocationService();

  Future<void> fetchEvents({String? inputCity = null}) async {
    _loading = true;
    _isError = false;
    _errorMessage = "";

    notifyListeners();

    try {
      inputCity ??= await _locationService.getCityName();
      _inputCity = inputCity;
      final cachedEventsResponse = await _cacheService.getCachedEventsResponse();

      if (cachedEventsResponse != null) {
        _localResponse = ApiResponse(
            events: cachedEventsResponse.events.map((event) => Event.fromJson(event)).toList(),
       );
      } else {
        // cache has expired or empty, go fetch from api
        final apiResponse = await _apiService.getEvents(inputCity);
        _localResponse = ApiResponse(
            events: apiResponse.events.map((event) => Event.fromJson(event)).toList(),
       );
        await _cacheService.saveEventsInCache(apiResponse.events);
      }
      print("EventProvider: providing ${_localResponse.events.length} events");
    } catch (error, stackTrace) {
      print("EventProvider: error=$error stackTrace=$stackTrace inputCity=$inputCity");
      _isError = true;
      _errorMessage = error.toString();
    }

    _loading = false;
    notifyListeners();
  }


  //fetch from supported_cities_api, if failed default to SUPPORTED_CITIES_DEFAULT
  Future<List<String>> getSupportedCities() async {
    final supportedList = await _apiService.getSupportedCitiesFromApi();
    if(supportedList != null){
      _cacheService.saveSupportedCitiesCache(supportedList);
      return supportedList;
    }else{
      return SUPPORTED_CITIES_DEFAULT;
    }
  }

  }
