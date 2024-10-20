
import 'package:geocoding/geocoding.dart';

class SupportedCity {
  final String city;
  final String country;
  final Location location; // "lat, long"

  SupportedCity({
    required this.city,
    required this.country,
    required this.location,
  });

  factory SupportedCity.fromJson(Map<String, dynamic> json) {
    return SupportedCity(
      city: json['city'],
      country: json['country'],
      location: parseLocationFromString(json['location']),
    );
  }


 static Location parseLocationFromString(String locationString) {
    // Split the string by comma and trim whitespace
    final parts = locationString.split(',').map((part) => part.trim()).toList();

    // Extract latitude and longitude
    final latitude = double.parse(parts[0]);
    final longitude = double.parse(parts[1]);

    // Create a Location object
    return Location(latitude: latitude, longitude: longitude, timestamp: DateTime.now());
  }

}

class SupportedCities {
  List<SupportedCity> supportedCities;

  SupportedCities({required this.supportedCities});

  factory SupportedCities.fromJson(List<dynamic> jsonList) {
    return SupportedCities(
      supportedCities: jsonList.map((json) => SupportedCity.fromJson(json)).toList(),
    );
  }
}
