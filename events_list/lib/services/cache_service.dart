import 'dart:convert';
import 'package:events_app/models/api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const cachePeriodMinutes = 24 * 60; // 24 hrs

  Future<void> cacheEvents(String inputCity, List<dynamic> events) async {
    print("CacheService: cacheEvents: inputCity ${inputCity}, events.size ${events.length} ");
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'events': events,
    };
    prefs.setString(inputCity, json.encode(cacheData));
  }

  Future<ApiResponse?> getCachedEventsResponse(String inputCity) async {

    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(inputCity);

    if (cacheString != null) {
      final cacheData = json.decode(cacheString);
      final currentCacheMilliSeconds = DateTime.now().millisecondsSinceEpoch - cacheData['timestamp'];
      if (currentCacheMilliSeconds < cachePeriodMinutes * 60 * 1000) {
        print("CacheService: getCachedEvents: inputCity ${inputCity} : currentCacheSeconds ${currentCacheMilliSeconds/1000}: returning cached data: $cacheData");
        return ApiResponse(events: cacheData['events']);
      }
    }
    print("CacheService: getCachedEvents: inputCity ${inputCity} : returning NULL!");
    return null;
  }
}
