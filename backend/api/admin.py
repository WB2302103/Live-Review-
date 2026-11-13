from django.contrib import admin
from .models import Event, FeedbackItem

@admin.register(Event)
class EventAdmin(admin.ModelAdmin):
    list_display = ('event_id', 'title', 'venue', 'status', 'organizer_name', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('title', 'venue', 'organizer_name', 'qr_code_token')

@admin.register(FeedbackItem)
class FeedbackItemAdmin(admin.ModelAdmin):
    list_display = ('feedback_id', 'event', 'overall_rating', 'sentiment', 'submitted_at')
    list_filter = ('sentiment', 'submitted_at')
    search_fields = ('comment', 'event__title')
