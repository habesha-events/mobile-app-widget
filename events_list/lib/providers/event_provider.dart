import 'package:events_app/models/api_response.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/location_service.dart';

class EventProvider with ChangeNotifier {
  ApiResponse get localResponse => _localResponse;
  ApiResponse _localResponse = ApiResponse(events: [], city: "", response_type: "");

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

  Future<void> fetchEvents({String? inputCity}) async {
    _loading = true;
    _isError = false;
    _errorMessage = "";

    notifyListeners();

    try {
      List<Event> _events = [];
      inputCity ??= await _locationService.getCityName();
      _inputCity = inputCity;
      final cachedEventsResponse = await _cacheService.getCachedEventsResponse(inputCity);

      if (cachedEventsResponse != null) {
        _events = cachedEventsResponse.events.map((event) => Event.fromJson(event)).toList();
        _localResponse = ApiResponse(events: _events, city: cachedEventsResponse.city, response_type: cachedEventsResponse.response_type);
      } else {
        // cache has expired or empty, go fetch from api
        final apiResponse = await _apiService.getEvents(inputCity);
        _events = apiResponse.events.map((e) => Event.fromJson(e)).toList();
        _localResponse = ApiResponse(events: _events, city:  apiResponse.city, response_type: apiResponse.response_type);
        await _cacheService.cacheEvents(inputCity, apiResponse.events, apiResponse.response_type, apiResponse.city);
      }
      print("EventProvider: providing ${_events.length} events");
    } catch (error) {
      print("EventProvider: error=$error inputCity=$inputCity");
      _isError = true;
      _errorMessage = error.toString();
    }

    _loading = false;
    notifyListeners();
  }
}
