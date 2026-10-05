from django.urls import path
from .views import FeedbackListCreateView, FeedbackRespondView
urlpatterns = [
    path('', FeedbackListCreateView.as_view()),
    path('<uuid:pk>/respond/', FeedbackRespondView.as_view()),
]
