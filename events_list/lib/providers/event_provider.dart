import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/supported_city.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/location_service.dart';

class EventProvider with ChangeNotifier {
  Events get events => _events;
  Events _events = Events(events: []);

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

  Future<void> fetchEvents({String? inputCity = null}) async {
    _loading = true;
    _isError = false;
    _errorMessage = "";

    notifyListeners();

    try {
      inputCity ??= await _locationService.getCityName();
      _inputCity = inputCity;
      var jsonList = await _cacheService.getCachedEventsResponse();

      if (jsonList == null) {
        // cache has expired or empty, go fetch from api
        jsonList = await _apiService.getEvents(inputCity);

        // save in cache
        await _cacheService.saveEventsInCache(jsonList);
      }
      _events = Events.fromJson(jsonList);

      print("EventProvider: providing ${_events.events.length} events");
    } catch (error, stackTrace) {
      print("EventProvider: error=$error stackTrace=$stackTrace inputCity=$inputCity");
      _isError = true;
      _errorMessage = error.toString();
    }

    _loading = false;
    notifyListeners();
  }


  Future<SupportedCities> getSupportedCities() async {
    var jsonList = await _cacheService.getCachedSupportedCities();
    if(jsonList == null){
      jsonList = await _apiService.getSupportedCitiesFromApi();
      if(jsonList != null){
        _cacheService.saveSupportedCitiesCache(jsonList);
      }else{
        jsonList = await _apiService.loadSupportedCitiesLocalJsonApiResponse();
      }
    }
    return SupportedCities.fromJson(jsonList);
  }

  }
