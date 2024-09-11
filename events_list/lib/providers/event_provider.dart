import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/location_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> get events => _events;
  List<Event> _events = [];

  String get city => _city;
  String _city = "";

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
      inputCity ??= await _locationService.getCityName();
      _city = inputCity;

      final cachedEvents = await _cacheService.getCachedEvents(inputCity);

      if (cachedEvents != null) {
        _events = cachedEvents.map((event) => Event.fromJson(event)).toList();
      } else {
        // cache has expired or empty, go fetch from api
        final apiResponse = await _apiService.getEvents(inputCity);
        _events = apiResponse.events.map((e) => Event.fromJson(e)).toList();
        _city = apiResponse.city;
        if(!SUPPORTED_CITIES.contains(_city)){
          //1st. check if its;s a list or not


          // _isError = true;
          // _errorMessage = "City $_city is not supported!";
          // _loading = false;
          // notifyListeners();
          // return;{

        }
        await _cacheService.cacheEvents(apiResponse.city, apiResponse.events);
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
