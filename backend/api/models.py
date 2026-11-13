from django.db import models

class Event(models.Model):
    STATUS_CHOICES = (
        ('upcoming', 'Upcoming'),
        ('live', 'Live'),
        ('closed', 'Closed'),
    )

    event_id = models.CharField(max_length=100, primary_key=True)
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, default='')
    venue = models.CharField(max_length=255)
    date_time = models.CharField(max_length=100)
    organizer_name = models.CharField(max_length=255, default='Youth Club & Organizers')
    qr_code_token = models.CharField(max_length=100, unique=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='upcoming')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.status})"

class FeedbackItem(models.Model):
    feedback_id = models.CharField(max_length=100, primary_key=True)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='feedbacks')
    overall_rating = models.FloatField(default=0.0)
    speaker_rating = models.FloatField(default=0.0)
    content_rating = models.FloatField(default=0.0)
    venue_rating = models.FloatField(default=0.0)
    comment = models.TextField(blank=True, default='')
    sentiment = models.CharField(max_length=20, default='Neutral') # 'Positive', 'Neutral', 'Negative'
    key_issues = models.JSONField(default=list, blank=True)
    client_token = models.CharField(max_length=255, blank=True, null=True)
    submitted_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Feedback for {self.event.title} - {self.sentiment}"
