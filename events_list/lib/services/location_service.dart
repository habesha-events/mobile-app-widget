import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';


class LocationService {
  String _DEFAULT_CITY = 'Seattle';

  Future<String> getCityName() async {
    var city = _DEFAULT_CITY;

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
          return _DEFAULT_CITY;
        }
      }

      print(
          "LocationService: getCityName: 2: _serviceEnabled ${_serviceEnabled}");

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          // return Future.error('Location permissions are denied');
          return _DEFAULT_CITY;
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
