import '../models/event_model.dart';
import '../models/feedback_model.dart';

class MockDataService {
  // Singleton pattern for shared state during demo
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal() {
    _seedInitialEvents();
  }

  final List<Event> events = [];
  final List<FeedbackItem> feedbacks = [];
  final Set<String> _submittedEventIds = {};

  void _seedInitialEvents() {
    // Clean initial state with no dummy sample events
  }

  bool isEventSubmitted(String eventId) {
    return _submittedEventIds.contains(eventId);
  }

  void markEventSubmitted(String eventId) {
    _submittedEventIds.add(eventId);
  }

  void unlockEventSubmission(String eventId) {
    _submittedEventIds.remove(eventId);
  }

  // Parse string date/time e.g. "Today, 10:10 PM" or "10:10 PM"
  DateTime? _resolveEventDateTime(Event event) {
    if (event.eventDateTime != null) {
      return event.eventDateTime;
    }

    try {
      final text = event.dateTime.toLowerCase();
      final now = DateTime.now();

      int year = now.year;
      int month = now.month;
      int day = now.day;

      if (text.contains('tomorrow')) {
        final tomorrow = now.add(const Duration(days: 1));
        year = tomorrow.year;
        month = tomorrow.month;
        day = tomorrow.day;
      }

      // Extract time e.g. "10:10 pm" or "3:00 pm"
      final timeRegExp = RegExp(r'(\d{1,2}):(\d{2})\s*(am|pm)');
      final match = timeRegExp.firstMatch(text);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        final ampm = match.group(3)!;

        if (ampm == 'pm' && hour < 12) {
          hour += 12;
        } else if (ampm == 'am' && hour == 12) {
          hour = 0;
        }

        return DateTime(year, month, day, hour, minute);
      }
    } catch (_) {}

    return null;
  }

  // Evaluate time-based automatic status transitions
  void _checkAutoStatusTransitions() {
    final now = DateTime.now();
    for (var event in events) {
      if (event.status == 'upcoming') {
        final eventTime = _resolveEventDateTime(event);
        if (eventTime != null && (now.isAfter(eventTime) || now.isAtSameMomentAs(eventTime))) {
          event.status = 'live';
        }
      }
    }
  }

  // Sorted Events: LIVE first, UPCOMING second, CLOSED last
  List<Event> getEvents() {
    _checkAutoStatusTransitions();

    List<Event> sortedList = List.from(events);
    sortedList.sort((a, b) {
      int weight(String status) {
        if (status == 'live') return 0;
        if (status == 'upcoming') return 1;
        return 2; // closed
      }
      return weight(a.status).compareTo(weight(b.status));
    });
    return sortedList;
  }

  Event? getEventByCode(String code) {
    _checkAutoStatusTransitions();
    try {
      return events.firstWhere((e) => e.qrCodeToken == code || e.id == code);
    } catch (_) {
      return null;
    }
  }

  void addEvent(Event event) {
    events.insert(0, event);
    _checkAutoStatusTransitions();
  }

  void updateEventStatus(String eventId, String newStatus) {
    try {
      final event = events.firstWhere((e) => e.id == eventId);
      event.status = newStatus;
    } catch (_) {}
  }

  void deleteEvent(String eventId) {
    events.removeWhere((e) => e.id == eventId);
    feedbacks.removeWhere((f) => f.eventId == eventId);
  }

  void addFeedback(FeedbackItem feedback) {
    feedbacks.insert(0, feedback);
  }

  List<FeedbackItem> getFeedbacksForEvent(String eventId) {
    return feedbacks.where((f) => f.eventId == eventId).toList();
  }

  Map<String, dynamic> getAnalytics(String eventId) {
    final eventFeedbacks = getFeedbacksForEvent(eventId);
    if (eventFeedbacks.isEmpty) {
      return {
        'responseCount': 0,
        'avgRating': 0.0,
        'speakerAvg': 0.0,
        'contentAvg': 0.0,
        'venueAvg': 0.0,
        'positivePct': 0.0,
        'neutralPct': 0.0,
        'negativePct': 0.0,
        'keyIssues': <String>[],
      };
    }

    double totalOverall = 0;
    double totalSpeaker = 0;
    double totalContent = 0;
    double totalVenue = 0;
    int positiveCount = 0;
    int neutralCount = 0;
    int negativeCount = 0;
    Set<String> allIssues = {};

    for (var f in eventFeedbacks) {
      totalOverall += f.overallRating;
      totalSpeaker += f.speakerRating;
      totalContent += f.contentRating;
      totalVenue += f.venueRating;
      if (f.sentiment == 'Positive') {
        positiveCount++;
      } else {
        if (f.sentiment == 'Neutral') {
          neutralCount++;
        } else {
          negativeCount++;
        }
      }
      allIssues.addAll(f.keyIssues);
    }

    int count = eventFeedbacks.length;
    return {
      'responseCount': count,
      'avgRating': (totalOverall / count),
      'speakerAvg': (totalSpeaker / count),
      'contentAvg': (totalContent / count),
      'venueAvg': (totalVenue / count),
      'positivePct': (positiveCount / count) * 100,
      'neutralPct': (neutralCount / count) * 100,
      'negativePct': (negativeCount / count) * 100,
      'keyIssues': allIssues.toList(),
    };
  }

  List<Map<String, dynamic>> getEmergencyAlerts(String? eventId) {
    final list = eventId != null ? getFeedbacksForEvent(eventId) : feedbacks;
    List<Map<String, dynamic>> alerts = [];

    int venueIssues = 0;
    int soundIssues = 0;

    for (var f in list) {
      final commentLower = f.comment.toLowerCase();
      if (f.venueRating <= 2.5 || commentLower.contains('ac') || commentLower.contains('heat') || commentLower.contains('room')) {
        venueIssues++;
      }
      if (f.speakerRating <= 2.5 || commentLower.contains('sound') || commentLower.contains('mic') || commentLower.contains('noise') || commentLower.contains('volume')) {
        soundIssues++;
      }
    }

    if (venueIssues >= 1) {
      alerts.add({
        'title': '⚠️ LIVE VENUE FACILITY ALERT',
        'desc': '$venueIssues Attendee(s) reported issues with Venue AC or Air Conditioning!',
        'type': 'Venue',
        'count': venueIssues,
      });
    }

    if (soundIssues >= 1) {
      alerts.add({
        'title': '🔊 LIVE AUDIO/MICROPHONE ALERT',
        'desc': '$soundIssues Attendee(s) reported issues with Sound System or Mic Volume!',
        'type': 'Audio',
        'count': soundIssues,
      });
    }

    return alerts;
  }
}
