import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/location_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _loading = false;
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();
  final LocationService _locationService = LocationService();

  List<Event> get events => _events;
  bool get loading => _loading;

  Future<void> fetchEvents({String? city}) async {
    _loading = true;
    notifyListeners();

    try {
      city ??= await _locationService.getCityName();
      final cachedEvents = await _cacheService.getCachedEvents(city);

      if (cachedEvents != null) {
        _events = cachedEvents.map((e) => Event.fromJson(e)).toList();
      } else {
        // cache has expired or empty, go fetch from api
        final response = await _apiService.getEvents(city);
        _events = response.map((e) => Event.fromJson(e)).toList();
        await _cacheService.cacheEvents(city, response);
      }
      print("EventProvider: providing ${_events.length} events");
    } catch (error) {
      print("EventProvider: error:$error city: $city");
      _events = [];
    }

    _loading = false;
    notifyListeners();
  }
}
