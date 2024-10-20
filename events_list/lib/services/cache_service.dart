import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';

class CacheService {
  static const CACHE_PERIOD_MINUTES = 24 * 60; // 24 hrs
  static const PREF_KEY_EVENTS = "PREF_KEY_EVENTS";
  static const PREF_KEY_SUPPORTED_CITIES = "PREF_KEY_SUPPORTED_CITIES";

  Future<void> saveEventsInCache(List<dynamic> events) async {
    print("CacheService: saveEventsInCache: events.size ${events.length} ");
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'events': events,
    };
    prefs.setString(PREF_KEY_EVENTS, json.encode(cacheData));
  }


  //returns jsonList
  Future<List<dynamic>?> getCachedEventsResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(PREF_KEY_EVENTS);
    if (cacheString != null) {
      final cacheData = json.decode(cacheString);
      final currentCacheMilliSeconds = DateTime.now().millisecondsSinceEpoch - cacheData['timestamp'];
      if (currentCacheMilliSeconds < CACHE_PERIOD_MINUTES * 60 * 1000) {
        print("CacheService: getCachedEventsResponse: currentCacheSeconds ${currentCacheMilliSeconds/1000}: returning cached data: $cacheData");
        return cacheData['events'];
      }
    }
    print("CacheService: getCachedEventsResponse: returning NULL!");
    return null;
  }

  Future<void> saveSupportedCitiesCache(List<dynamic> supportedCities) async {
    print("CacheService: saveSupportedCitiesCache: supportedCities.size ${supportedCities.length} ");
    final prefs = await SharedPreferences.getInstance();
    final cacheData = supportedCities;
    prefs.setString(PREF_KEY_SUPPORTED_CITIES, json.encode(cacheData));
  }

  //returns jsonList
  Future<List<dynamic>?> getCachedSupportedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(PREF_KEY_SUPPORTED_CITIES);
    if (cacheString != null) {
      final cacheData = jsonDecode(cacheString);
      print("CacheService: getCachedSupportedCities: $cacheData");
      return cacheData;
    }
    print("CacheService: getCachedSupportedCities: returning NULL!");
    return null;
  }
}
