class Event {
  final String position;
  final String imageUrl;
  final String title;
  final String startTime;
  final String price;

  Event({
    required this.position,
    required this.imageUrl,
    required this.title,
    required this.startTime,
    required this.price,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      position: json['Position'],
      imageUrl: json['image_url'],
      title: json['title'],
      startTime: json['start_time'],
      price: json['price'],
    );
  }
}
