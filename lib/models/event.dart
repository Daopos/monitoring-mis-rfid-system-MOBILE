// event.dart
class Event {
  final int id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String status;

  Event({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      status: json['status'],
    );
  }
}
