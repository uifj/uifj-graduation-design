class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String imageUrl;
  final double price;
  final int availableSeats;
  final List<String> speakers;
  final List<String> tags;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.price,
    required this.availableSeats,
    required this.speakers,
    required this.tags,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      date: DateTime.parse(json['date']),
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
      availableSeats: json['availableSeats'],
      speakers: List<String>.from(json['speakers']),
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'price': price,
      'availableSeats': availableSeats,
      'speakers': speakers,
      'tags': tags,
    };
  }
}
