from django.urls import path
from .views import (
    RequestOTPView, VerifyOTPView, MeView,
    DealerProfileView, AdminVerifyDealerView, PendingDealersView,
)

urlpatterns = [
    path('otp/request/', RequestOTPView.as_view()),
    path('otp/verify/', VerifyOTPView.as_view()),
    path('me/', MeView.as_view()),
    path('dealer/profile/', DealerProfileView.as_view()),
    path('admin/dealers/pending/', PendingDealersView.as_view()),
    path('admin/dealers/<uuid:dealer_id>/verify/', AdminVerifyDealerView.as_view()),
]
