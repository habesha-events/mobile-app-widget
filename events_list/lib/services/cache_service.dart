import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const cacheKey = 'cached_events';

  Future<void> cacheEvents(String city, List<dynamic> events) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'city': city,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': events,
    };
    prefs.setString(cacheKey, json.encode(cacheData));
  }

  Future<List<dynamic>?> getCachedEvents(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(cacheKey);

    if (cacheString != null) {
      final cacheData = json.decode(cacheString);
      if (cacheData['city'] == city &&
          DateTime.now().millisecondsSinceEpoch - cacheData['timestamp'] < 7200000) {
        return cacheData['data'];
      }
    }
    return null;
  }
}
