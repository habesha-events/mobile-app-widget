class Event {
  final String? position; // this is the id of the event
  final String? imageUrl;
  final String? title;
  final String? startTime;
  final String? eventUrl;
  final String? price;
  final String? city;

  Event({
    required this.position,
    required this.imageUrl,
    required this.title,
    required this.startTime,
    required this.eventUrl,
    required this.price,
    required this.city,
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
    );
  }

  String? getPriceDisplayText(){
    return price?.replaceAll("From", "");
  }
}
