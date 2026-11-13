from django.urls import path
from .views import (
    EventListCreateView, EventDetailView, FeedbackCreateView,
    EventAnalyticsView, EmergencyAlertsView, ExportExcelView
)

urlpatterns = [
    path('events/', EventListCreateView.as_view(), name='event_list_create'),
    path('events/create/', EventListCreateView.as_view(), name='event_create'),
    path('events/<str:pk>/', EventDetailView.as_view(), name='event_detail'),
    path('feedbacks/create/', FeedbackCreateView.as_view(), name='feedback_create'),
    path('events/<str:event_id>/analytics/', EventAnalyticsView.as_view(), name='event_analytics'),
    path('events/<str:event_id>/alerts/', EmergencyAlertsView.as_view(), name='event_alerts'),
    path('alerts/', EmergencyAlertsView.as_view(), name='all_alerts'),
    path('events/<str:event_id>/export/excel/', ExportExcelView.as_view(), name='export_excel'),
]
