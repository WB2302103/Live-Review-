from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

def root_welcome(request):
    return JsonResponse({
        'status': 'online',
        'app_name': 'EventPulse Django REST API Platform',
        'events_api': 'http://127.0.0.1:8000/api/events/',
        'alerts_api': 'http://127.0.0.1:8000/api/alerts/',
        'admin_panel': 'http://127.0.0.1:8000/admin/',
    })

urlpatterns = [
    path('', root_welcome, name='root_welcome'),
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
]
