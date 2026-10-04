from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.utils import timezone
from .models import GoldPrice
from .serializers import GoldPriceSerializer, GoldPriceCreateSerializer


class CurrentPricesView(APIView):
    """Return latest price for each karat (24K, 22K, 18K)."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        result = []
        for karat in ['24K', '22K', '18K']:
            price = GoldPrice.objects.filter(
                karat=karat, is_active=True
            ).order_by('-effective_at').first()
            if price:
                result.append(GoldPriceSerializer(price).data)
            else:
                result.append({
                    'karat': karat,
                    'price_per_gram': None,
                    'currency': 'TZS',
                    'is_stale': True,
                    'message': 'No price available',
                })
        return Response({'prices': result, 'fetched_at': timezone.now().isoformat()})


class PriceHistoryView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = GoldPriceSerializer

    def get_queryset(self):
        qs = GoldPrice.objects.filter(is_active=True)
        karat = self.request.query_params.get('karat')
        if karat:
            qs = qs.filter(karat=karat)
        return qs[:50]


class SetPriceView(generics.CreateAPIView):
    """Admin only – publish a new market price."""
    permission_classes = [IsAuthenticated]
    serializer_class = GoldPriceCreateSerializer

    def create(self, request, *args, **kwargs):
        if request.user.role != 'admin' and not request.user.is_staff:
            return Response({'detail': 'Admin only.'}, status=403)
        ser = self.get_serializer(data=request.data)
        ser.is_valid(raise_exception=True)
        price = ser.save(created_by=request.user)
        return Response(GoldPriceSerializer(price).data, status=201)
