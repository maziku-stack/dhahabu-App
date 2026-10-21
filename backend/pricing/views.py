from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics
from django.utils import timezone
from datetime import timedelta
from django.conf import settings
from integrations.providers import NullCommissionPriceProvider, get_provider, validate_commission_prices
from .models import GoldPrice, ReferencePriceSnapshot
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


class ReferencePriceView(APIView):
    """Serve cached third-party reference data without calling providers inline."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        snapshot = ReferencePriceSnapshot.objects.first()
        if snapshot is None:
            return Response({
                'price': None,
                'official': False,
                'status': 'not_available',
                'message': 'No indicative reference price has been fetched yet.',
            }, status=503)

        now = timezone.now()
        stale = (
            now - snapshot.gold_effective_at > timedelta(minutes=30)
            or timezone.localdate() - snapshot.fx_effective_date > timedelta(days=2)
        )
        return Response({
            'price': {
                'value': snapshot.tzs_per_gram,
                'currency': 'TZS',
                'unit': 'gram',
                'basis': '24K international spot estimate',
                'gold_usd_per_troy_ounce': snapshot.gold_usd_per_troy_ounce,
                'usd_to_tzs': snapshot.usd_to_tzs,
            },
            'official': False,
            'status': 'stale' if stale else 'available',
            'sources': [snapshot.gold_source, snapshot.fx_source],
            'gold_effective_at': snapshot.gold_effective_at,
            'fx_effective_date': snapshot.fx_effective_date,
            'fetched_at': snapshot.fetched_at,
            'is_stale': stale,
            'message': 'Indicative market reference only; not an official Commission price or sale assessment.',
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
