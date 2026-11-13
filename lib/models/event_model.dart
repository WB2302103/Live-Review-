class Event {
  final String id;
  final String title;
  final String description;
  final String venue;
  final String dateTime;
  final DateTime? eventDateTime;
  final String organizerName;
  final String qrCodeToken;
  String status; // 'live', 'upcoming', 'closed'

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.dateTime,
    this.eventDateTime,
    required this.organizerName,
    required this.qrCodeToken,
    this.status = 'upcoming',
  });
}
