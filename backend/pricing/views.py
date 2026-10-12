from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics
from django.utils import timezone
from django.conf import settings
from integrations.providers import NullCommissionPriceProvider, get_provider, validate_commission_prices
from .models import GoldPrice
from .serializers import GoldPriceSerializer

class CurrentPricesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            provider = get_provider('DH_COMMISSION_PRICE_PROVIDER', NullCommissionPriceProvider)
            prices = validate_commission_prices(provider.get_prices())
        except Exception:
            prices = None
        if prices is None:
            return Response({
                'prices': [], 'official': False, 'status': 'provider_error',
                'message': 'The Commission feed failed verification or is unavailable.',
                'fetched_at': timezone.now().isoformat(),
            }, status=503)
        configured = bool(settings.DH_COMMISSION_PRICE_PROVIDER)
        return Response({
            'prices': prices,
            'official': bool(prices),
            'status': 'available' if prices else ('no_current_prices' if configured else 'not_configured'),
            'message': None if prices else ('No current official prices were returned.' if configured else 'Official Mining Commission price feed is not connected.'),
            'fetched_at': timezone.now().isoformat(),
        })

class PriceHistoryView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = GoldPriceSerializer

    def get_queryset(self):
        # Local/admin-entered prices are not an authoritative price history.
        return GoldPrice.objects.none()

class SetPriceView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        return Response({
            'detail': 'Manual price entry is disabled; an approved Mining Commission provider is required.'
        }, status=503)
