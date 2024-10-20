import 'dart:convert';
import 'package:events_app/models/api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const CACHE_PERIOD_MINUTES = 24 * 60; // 24 hrs
  static const PREF_KEY_EVENTS = "PREF_KEY_EVENTS";

  Future<void> saveEventsInCache(List<dynamic> events) async {
    print("CacheService: saveEvents: events.size ${events.length} ");
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'events': events,
    };
    prefs.setString(PREF_KEY_EVENTS, json.encode(cacheData));
  }

  Future<ApiResponse?> getCachedEventsResponse() async {

    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(PREF_KEY_EVENTS);

    if (cacheString != null) {
      final cacheData = json.decode(cacheString);
      final currentCacheMilliSeconds = DateTime.now().millisecondsSinceEpoch - cacheData['timestamp'];
      if (currentCacheMilliSeconds < CACHE_PERIOD_MINUTES * 60 * 1000) {
        print("CacheService: getCachedEvents: currentCacheSeconds ${currentCacheMilliSeconds/1000}: returning cached data: $cacheData");
        return ApiResponse(events: cacheData['events']);
      }
    }
    print("CacheService: getCachedEvents: returning NULL!");
    return null;
  }
}
