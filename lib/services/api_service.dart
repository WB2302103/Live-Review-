import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../models/feedback_model.dart';

/// Django REST Framework API Service Client for EventPulse
/// Connects Flutter Frontend to Django Backend endpoints.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Django Backend API Base URL
  // Default Web/Browser: http://localhost:8000/api
  // Android Emulator: http://10.0.2.2:8000/api
  String baseUrl = kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';

  bool isBackendConnected = false;

  /// Check Django Server Connectivity
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events/')).timeout(
        const Duration(seconds: 3),
      );
      isBackendConnected = response.statusCode == 200;
      return isBackendConnected;
    } catch (_) {
      isBackendConnected = false;
      return false;
    }
  }

  /// Get Events from Django REST API
  Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((jsonMap) {
          return Event(
            id: jsonMap['event_id'],
            title: jsonMap['title'],
            description: jsonMap['description'] ?? '',
            venue: jsonMap['venue'],
            dateTime: jsonMap['date_time'],
            organizerName: jsonMap['organizer_name'] ?? 'Youth Club & Organizers',
            qrCodeToken: jsonMap['qr_code_token'],
            status: jsonMap['status'] ?? 'upcoming',
          );
        }).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Django fetchEvents error: $e');
    }
    return [];
  }

  /// Create Event via Django REST API
  Future<bool> createEvent(Event event) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/create/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'event_id': event.id,
          'title': event.title,
          'description': event.description,
          'venue': event.venue,
          'date_time': event.dateTime,
          'organizer_name': event.organizerName,
          'qr_code_token': event.qrCodeToken,
          'status': event.status,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('Django createEvent error: $e');
      return false;
    }
  }

  /// Submit Feedback via Django REST API (with Bangla NLP & Anti-Spam Check)
  Future<bool> submitFeedback(FeedbackItem feedback, String clientToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedbacks/create/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'feedback_id': feedback.id,
          'event': feedback.eventId,
          'overall_rating': feedback.overallRating,
          'speaker_rating': feedback.speakerRating,
          'content_rating': feedback.contentRating,
          'venue_rating': feedback.venueRating,
          'comment': feedback.comment,
          'client_token': clientToken,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('Django submitFeedback error: $e');
      return false;
    }
  }

  /// Fetch Analytics Summary from Django REST API
  Future<Map<String, dynamic>?> fetchAnalytics(String eventId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events/$eventId/analytics/'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print('Django fetchAnalytics error: $e');
    }
    return null;
  }
}
