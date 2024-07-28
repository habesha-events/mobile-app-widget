import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const cachePeriodMinutes = 24 * 60; // 24 hrs

  Future<void> cacheEvents(String city, List<dynamic> events) async {
    print("CacheService: cacheEvents: city ${city}, events.size ${events.length}");
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'city': city,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'events': events,
    };
    prefs.setString(city, json.encode(cacheData));
  }

  Future<List<dynamic>?> getCachedEvents(String city) async {

    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(city);

    if (cacheString != null) {
      final cacheData = json.decode(cacheString);
      final currentCacheMilliSeconds = DateTime.now().millisecondsSinceEpoch - cacheData['timestamp'];
      if (currentCacheMilliSeconds < cachePeriodMinutes * 60 * 1000) {
        print("CacheService: getCachedEvents: city ${city} : currentCacheSeconds ${currentCacheMilliSeconds/1000}: returning cached events!");
        return cacheData['events'];
      }
    }
    print("CacheService: getCachedEvents: city ${city} : returning NULL!");
    return null;
  }
}
