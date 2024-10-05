import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

List<String> SUPPORTED_CITIES = ['Washington, DC',
  'Addis Ababa',
  'Nairobi', 'Dubai'
  'Johannesburg', 'Minneapolis', 'Los Angeles', 'New York City', 'Seattle', 'Dallas', 'Atlanta', 'Denver', 'San Francisco', 'Boston', 'Houston', 'Chicago', 'San Diego', 'Philadelphia', 'Phoenix', 'Portland', 'Austin', 'Miami', 'Detroit', 'Baltimore', 'Toronto', 'Calgary', 'Edmonton', 'Vancouver', 'Montreal', 'Ottawa', 'Winnipeg', 'Hamilton', 'Kitchener', 'London', 'Halifax', 'Victoria', 'Quebec City', 'Surrey', 'Mississauga', 'Burnaby', 'Regina', 'Saskatoon', 'Windsor', 'Oshawa', 'London', 'Frankfurt', 'Stockholm', 'Rome', 'Amsterdam', 'Paris', 'Berlin', 'Oslo', 'Brussels', 'Copenhagen', 'Madrid', 'Vienna', 'Zurich', 'Munich', 'Lisbon', 'Helsinki', 'Dublin', 'Athens', 'Prague', 'Warsaw'];
String defaultCity = 'Seattle';

class LocationService {
  Future<String> getCityName() async {
    var city = defaultCity;

    try {
      final loc.Location location = loc.Location();
      bool _serviceEnabled;
      loc.PermissionStatus _permissionGranted;
      loc.LocationData _locationData;

      print("LocationService: getCityName: 1");

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          // return Future.error('Location services are disabled.');
          return defaultCity;
        }
      }

      print(
          "LocationService: getCityName: 2: _serviceEnabled ${_serviceEnabled}");

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          // return Future.error('Location permissions are denied');
          return defaultCity;
        }
      }
      print(
          "LocationService: getCityName: 3: _permissionGranted ${_permissionGranted}");

      _locationData = await location.getLocation();
      print("LocationService: getCityName: 4: latitude ${_locationData
          .latitude}, longitude ${ _locationData.longitude}");

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            _locationData.latitude!, _locationData.longitude!);
        city = placemarks.first.locality ?? 'Unknown';
      } catch (e) {
        print("LocationService: PlaceMark Error: ${e}");
      }

      print("LocationService: getCityName: 5: city ${city}");
    } catch (e) {
      print("LocationService: General Error: ${e}");
    }

    return city;
  }
}
