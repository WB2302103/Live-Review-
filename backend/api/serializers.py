from rest_framework import serializers
from .models import Event, FeedbackItem

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = [
            'event_id', 'title', 'description', 'venue', 'date_time',
            'organizer_name', 'qr_code_token', 'status', 'created_at'
        ]

class FeedbackItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = FeedbackItem
        fields = [
            'feedback_id', 'event', 'overall_rating', 'speaker_rating',
            'content_rating', 'venue_rating', 'comment', 'sentiment',
            'key_issues', 'client_token', 'submitted_at'
        ]
