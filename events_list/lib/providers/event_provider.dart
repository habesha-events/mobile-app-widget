import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../models/event.dart';
import '../models/supported_city.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/location_service.dart';
import 'dart:math';

class EventProvider with ChangeNotifier {
  Events get events => _events;
  Events _events = Events(events: []);

  String get inputCity => _inputCity;
  String _inputCity= '';

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

      // if inputCity is not in SUPPORTED_CITIES, map it to the nearest supported city
      if (!SUPPORTED_CITIES.map((supportedCity) => supportedCity.city).toList().contains(_inputCity)) {
        _inputCity = _getNearestSupportedCity().city;
      }

      var eventsJsonList = await _cacheService.getCachedEventsResponse();
      if (eventsJsonList == null) {
        // cache has expired or empty, go fetch from api
        eventsJsonList = await _apiService.getEvents(_inputCity);

        // save in cache
        await _cacheService.saveEventsInCache(eventsJsonList);
      }
      _events = Events.fromJson(eventsJsonList);

      //1. set location data in events model : todo move to backend
      _populateEventsLocation();
      //2. sort
      _sortEventsByDistance();

      print("EventProvider: providing ${_events.events.length} events");
    } catch (error, stackTrace) {
      print("EventProvider: error=$error inputCity=$_inputCity stackTrace=$stackTrace");
      _isError = true;
      _errorMessage = error.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<SupportedCities> getSupportedCities(
      forceRefreshSupportedCities) async {
    var jsonList = await _cacheService.getCachedSupportedCities();
    if (jsonList == null || forceRefreshSupportedCities) {
      jsonList = await _apiService.getSupportedCitiesFromApi();
      if (jsonList != null) {
        _cacheService.saveSupportedCitiesCache(jsonList);
      } else {
        jsonList = await _apiService.loadSupportedCitiesLocalJsonApiResponse();
      }
    }
    return SupportedCities.fromJson(jsonList);
  }


  SupportedCity _getNearestSupportedCity() {
    late SupportedCity nearestCity;
    double minDistance = double.infinity;

    var inputLocation = _locationService.fetchedLocation;
    for (SupportedCity supportedCity in SUPPORTED_CITIES) {
      double distance = _calculateDistance(
        inputLocation.latitude, inputLocation.longitude,
        supportedCity.latitude, supportedCity.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = supportedCity;
      }
    }

    print("EventProvider: _getNearestSupportedCity=${nearestCity.toString()}");
    return nearestCity;
  }

  // Haversine's formula to calculate distance between two lat/lng points in kilometers
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double radiusOfEarth = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radiusOfEarth * c;
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }



// Function to populate the location field of events
  void _populateEventsLocation() {
    List<Event> populatedEvents = [];
    for (var event in  _events.events) {
      // Find the matching supported city for the event's city
      final matchingSupportedCity = SUPPORTED_CITIES.firstWhere(
            (supportedCity) => supportedCity.city == event.city,
        orElse: () => SupportedCity(city: '', country: '', latitude: 0, longitude: 0),
      );

      // Populate the location if a matching city is found
      if (matchingSupportedCity.city.isNotEmpty) {
        event.latitude = matchingSupportedCity.latitude;
        event.longitude = matchingSupportedCity.longitude;
        populatedEvents.add(event);
      }
    }
    _events.events = populatedEvents;
  }

  // Function to sort events based on proximity to input location
    _sortEventsByDistance() {
      final inputSupportedCity = SUPPORTED_CITIES.firstWhere(
            (supportedCity) => supportedCity.city == _inputCity,
        orElse: () => SupportedCity(city: '', country: '', latitude: 0, longitude: 0),
      );
      var latitude = inputSupportedCity.latitude;
      var longitude = inputSupportedCity.longitude;

    // Sort the events list by distance to the input location
    _events.events.sort((event1, event2) {

      // Calculate distances
      double distance1 = _calculateDistance(latitude, longitude,
          event1.latitude, event1.longitude);
      double distance2 = _calculateDistance(latitude, longitude,
          event2.latitude, event2.longitude);

      // Sort by distance (ascending)
      return distance1.compareTo(distance2);
    });

  }

  //debug method to print large string
  void _printLargeString(String text) {
    const int chunkSize = 800; // The max size per print call
    for (int i = 0; i < text.length; i += chunkSize) {
      print(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
  }
}
