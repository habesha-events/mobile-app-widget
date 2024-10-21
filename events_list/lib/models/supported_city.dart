
import 'package:geocoding/geocoding.dart';

class SupportedCity {
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  SupportedCity({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory SupportedCity.fromJson(Map<String, dynamic> json) {
    return SupportedCity(
      city: json['city'],
      country: json['country'],
      latitude: json['latitude'],
      longitude: json['longitude'] ,
    );
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
