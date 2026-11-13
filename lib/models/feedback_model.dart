class FeedbackItem {
  final String id;
  final String eventId;
  final double overallRating;
  final double speakerRating;
  final double contentRating;
  final double venueRating;
  final String comment;
  final DateTime submittedAt;
  final String sentiment; // 'Positive', 'Neutral', 'Negative'
  final List<String> keyIssues; // e.g. ['Sound Quality', 'Engaging Speaker']

  FeedbackItem({
    required this.id,
    required this.eventId,
    required this.overallRating,
    required this.speakerRating,
    required this.contentRating,
    required this.venueRating,
    required this.comment,
    required this.submittedAt,
    required this.sentiment,
    required this.keyIssues,
  });
}
