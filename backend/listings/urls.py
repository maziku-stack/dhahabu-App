from django.urls import path
from .views import ListingListCreateView, ListingDetailView
urlpatterns = [
    path('', ListingListCreateView.as_view()),
    path('<uuid:pk>/', ListingDetailView.as_view()),
]
