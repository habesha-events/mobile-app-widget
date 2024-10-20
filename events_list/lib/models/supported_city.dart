
import 'package:geocoding/geocoding.dart';

class SupportedCity {
  final String city;
  final String country;
  final Location location;

  SupportedCity({
    required this.city,
    required this.country,
    required this.location,
  });

  factory SupportedCity.fromJson(Map<String, dynamic> json) {
    return SupportedCity(
      city: json['city'],
      country: json['country'],
      location: json['location'],
    );
  }


}
