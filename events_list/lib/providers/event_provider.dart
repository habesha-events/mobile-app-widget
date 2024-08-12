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


  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();
  final LocationService _locationService = LocationService();

  Future<void> fetchEvents({String? inputCity}) async {
    _loading = true;
    notifyListeners();

    try {
      inputCity ??= await _locationService.getCityName();
      final cachedEvents = await _cacheService.getCachedEvents(inputCity);

      if (cachedEvents != null) {
        _events = cachedEvents.map((event) => Event.fromJson(event)).toList();
        _city = inputCity;
      } else {
        // cache has expired or empty, go fetch from api
        final apiResponse = await _apiService.getEvents(inputCity);
        _events = apiResponse.events.map((e) => Event.fromJson(e)).toList();
        _city = apiResponse.city;
        await _cacheService.cacheEvents(apiResponse.city, apiResponse.events);
      }
      print("EventProvider: providing ${_events.length} events");
    } catch (error) {
      print("EventProvider: error:$error inputCity: $inputCity");
      _events = [];
    }

    _loading = false;
    notifyListeners();
  }
}
