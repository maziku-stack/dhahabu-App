from django.urls import path
from .views import CurrentPricesView, PriceHistoryView, ReferencePriceView, SetPriceView
urlpatterns = [
    path('current/', CurrentPricesView.as_view()),
    path('reference/', ReferencePriceView.as_view()),
    path('history/', PriceHistoryView.as_view()),
    path('set/', SetPriceView.as_view()),
]
