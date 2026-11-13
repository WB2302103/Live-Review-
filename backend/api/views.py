import csv
import io
from django.http import HttpResponse, JsonResponse
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from .models import Event, FeedbackItem
from .serializers import EventSerializer, FeedbackItemSerializer
from .nlp_sentiment import BanglaSentimentAnalyzer

class EventListCreateView(APIView):
    def get(self, request):
        events = Event.objects.all()
        # Sort: live first, upcoming second, closed last
        status_weights = {'live': 0, 'upcoming': 1, 'closed': 2}
        sorted_events = sorted(events, key=lambda e: status_weights.get(e.status, 3))
        serializer = EventSerializer(sorted_events, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = EventSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class EventDetailView(APIView):
    def get(self, request, pk):
        event = Event.objects.filter(event_id=pk).first() or Event.objects.filter(qr_code_token=pk).first()
        if not event:
            return Response({'error': 'Event not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = EventSerializer(event)
        return Response(serializer.data)

    def patch(self, request, pk):
        event = get_object_or_404(Event, event_id=pk)
        new_status = request.data.get('status')
        if new_status:
            event.status = new_status
            event.save()
            return Response(EventSerializer(event).data)
        return Response({'error': 'Status is required'}, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        event = get_object_or_404(Event, event_id=pk)
        event.delete()
        return Response({'message': 'Deleted successfully'}, status=status.HTTP_200_OK)

class FeedbackCreateView(APIView):
    def post(self, request):
        data = request.data.copy()
        event_id = data.get('event')
        client_token = data.get('client_token')

        # Anti-Spam Check: Check if duplicate submission exists for client_token on this event
        if client_token:
            existing = FeedbackItem.objects.filter(event_id=event_id, client_token=client_token).first()
            if existing:
                return Response(
                    {'error': 'Feedback already submitted for this event.'},
                    status=status.HTTP_429_TOO_MANY_REQUESTS
                )

        # Run Bangla & Banglish NLP Sentiment Analysis Engine
        overall_rating = float(data.get('overall_rating', 3.0))
        speaker_rating = float(data.get('speaker_rating', overall_rating))
        content_rating = float(data.get('content_rating', overall_rating))
        venue_rating = float(data.get('venue_rating', overall_rating))
        comment = data.get('comment', '')

        nlp_result = BanglaSentimentAnalyzer.analyze_comment(
            comment,
            overall_val=overall_rating,
            speaker_val=speaker_rating,
            content_val=content_rating,
            venue_val=venue_rating,
        )

        data['sentiment'] = nlp_result['sentiment']
        data['key_issues'] = nlp_result['key_issues']

        serializer = FeedbackItemSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class EventAnalyticsView(APIView):
    def get(self, request, event_id):
        feedbacks = FeedbackItem.objects.filter(event_id=event_id)
        count = feedbacks.count()

        if count == 0:
            return Response({
                'responseCount': 0,
                'avgRating': 0.0,
                'speakerAvg': 0.0,
                'contentAvg': 0.0,
                'venueAvg': 0.0,
                'positivePct': 0.0,
                'neutralPct': 0.0,
                'negativePct': 0.0,
                'keyIssues': [],
            })

        total_overall = sum(f.overall_rating for f in feedbacks)
        total_speaker = sum(f.speaker_rating for f in feedbacks)
        total_content = sum(f.content_rating for f in feedbacks)
        total_venue = sum(f.venue_rating for f in feedbacks)

        positive_count = feedbacks.filter(sentiment='Positive').count()
        neutral_count = feedbacks.filter(sentiment='Neutral').count()
        negative_count = feedbacks.filter(sentiment='Negative').count()

        all_issues = set()
        for f in feedbacks:
            if isinstance(f.key_issues, list):
                all_issues.update(f.key_issues)

        return Response({
            'responseCount': count,
            'avgRating': round(total_overall / count, 1),
            'speakerAvg': round(total_speaker / count, 1),
            'contentAvg': round(total_content / count, 1),
            'venueAvg': round(total_venue / count, 1),
            'positivePct': round((positive_count / count) * 100, 1),
            'neutralPct': round((neutral_count / count) * 100, 1),
            'negativePct': round((negative_count / count) * 100, 1),
            'keyIssues': list(all_issues),
        })

class EmergencyAlertsView(APIView):
    def get(self, request, event_id=None):
        feedbacks = FeedbackItem.objects.filter(event_id=event_id) if event_id else FeedbackItem.objects.all()

        venue_issues = 0
        sound_issues = 0

        for f in feedbacks:
            c_lower = f.comment.lower()
            if f.venue_rating <= 2.5 or any(k in c_lower for k in ['ac', 'heat', 'room', 'venue']):
                venue_issues += 1
            if f.speaker_rating <= 2.5 or any(k in c_lower for k in ['sound', 'mic', 'volume', 'noise']):
                sound_issues += 1

        alerts = []
        if venue_issues >= 1:
            alerts.append({
                'title': '⚠️ LIVE VENUE FACILITY ALERT',
                'desc': f'{venue_issues} Attendee(s) reported issues with Venue AC or Air Conditioning!',
                'type': 'Venue',
                'count': venue_issues,
            })
        if sound_issues >= 1:
            alerts.append({
                'title': '🔊 LIVE AUDIO/MICROPHONE ALERT',
                'desc': f'{sound_issues} Attendee(s) reported issues with Sound System or Mic Volume!',
                'type': 'Audio',
                'count': sound_issues,
            })

        return Response(alerts)

class ExportExcelView(APIView):
    def get(self, request, event_id):
        event = get_object_or_404(Event, event_id=event_id)
        feedbacks = FeedbackItem.objects.filter(event_id=event_id)

        response = HttpResponse(content_type='text/csv')
        filename = f"{event.title.replace(' ', '_')}_Feedback_Data.csv"
        response['Content-Disposition'] = f'attachment; filename="{filename}"'

        writer = csv.writer(response)
        writer.writerow(['Feedback ID', 'Submitted At', 'Overall Rating', 'Speaker Rating', 'Content Rating', 'Venue Rating', 'Sentiment', 'Comment', 'Issues'])

        for f in feedbacks:
            issues_str = ', '.join(f.key_issues) if isinstance(f.key_issues, list) else ''
            writer.writerow([
                f.feedback_id,
                f.submitted_at.strftime('%Y-%m-%d %H:%M:%S'),
                f.overall_rating,
                f.speaker_rating,
                f.content_rating,
                f.venue_rating,
                f.sentiment,
                f.comment,
                issues_str
            ])

        return response
