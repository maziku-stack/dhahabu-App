from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Listing
from .serializers import ListingSerializer, ListingCreateSerializer

class ListingListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return ListingCreateSerializer
        return ListingSerializer

    def get_queryset(self):
        user = self.request.user
        qs = Listing.objects.select_related('miner')
        mine = self.request.query_params.get('mine')
        status_f = self.request.query_params.get('status', 'open')
        if mine == '1' or user.role == 'miner':
            if mine == '1' or self.request.query_params.get('only_mine') == '1':
                return qs.filter(miner=user)
        if user.role == 'miner' and self.request.method == 'GET' and mine != '0':
            # default for miner: own listings unless browsing
            if self.request.query_params.get('browse') != '1':
                return qs.filter(miner=user)
        if status_f:
            qs = qs.filter(status=status_f)
        karat = self.request.query_params.get('karat')
        region = self.request.query_params.get('region')
        if karat:
            qs = qs.filter(karat=karat)
        if region:
            qs = qs.filter(region__icontains=region)
        return qs

    def create(self, request, *args, **kwargs):
        if request.user.role != 'miner':
            return Response({'detail': 'Only miners can create listings.'}, status=403)
        ser = self.get_serializer(data=request.data)
        ser.is_valid(raise_exception=True)
        listing = ser.save(
            miner=request.user,
            region=ser.validated_data.get('region') or request.user.region,
        )
        return Response(ListingSerializer(listing).data, status=201)

class ListingDetailView(generics.RetrieveUpdateAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Listing.objects.select_related('miner')
    serializer_class = ListingSerializer

    def patch(self, request, *args, **kwargs):
        listing = self.get_object()
        if request.user.id != listing.miner_id and request.user.role != 'admin':
            return Response({'detail': 'Forbidden'}, status=403)
        status_val = request.data.get('status')
        if status_val in ('cancelled', 'open', 'sold'):
            listing.status = status_val
            listing.save(update_fields=['status', 'updated_at'])
        return Response(ListingSerializer(listing).data)
