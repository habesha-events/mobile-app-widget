import 'package:events_app/models/supported_city.dart';
import 'package:geocoding/geocoding.dart';

class Event {
  final String? position; // this is the id of the event
  final String? imageUrl;
  final String? title;
  final String? startTime;
  final String? eventUrl;
  final String? price;
  final String? city;
   double latitude;
   double longitude;

  Event({
    required this.position,
    required this.imageUrl,
    required this.title,
    required this.startTime,
    required this.eventUrl,
    required this.price,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      position: json['Position'],
      imageUrl: json['image_url'],
      title: json['event_title'],
      startTime: json['start_time'],
      eventUrl: json['event_url'],
      price: json['price'],
      city: json['city'],
      latitude: 0,
      longitude: 0,
    );
  }

  String? getPriceDisplayText() {
    return price?.replaceAll("From", "");
  }

  @override
  String toString() {
    return 'Event{position: $position, imageUrl: $imageUrl, title: $title, startTime: $startTime, price: $price}';
  }
}

class Events {
  List<Event> events;

  Events({required this.events});

  factory Events.fromJson(List<dynamic> jsonList) {
    return Events(
      events: jsonList.map((json) => Event.fromJson(json)).toList(),
    );
  }
}
