from rest_framework import serializers
from .models import Listing

class ListingSerializer(serializers.ModelSerializer):
    miner_name = serializers.CharField(source='miner.full_name', read_only=True)
    miner_phone = serializers.CharField(source='miner.phone', read_only=True)

    class Meta:
        model = Listing
        fields = (
            'id', 'miner', 'miner_name', 'miner_phone', 'weight_grams', 'karat',
            'asking_price', 'price_per_gram', 'notes', 'region', 'status',
            'photo', 'created_at', 'updated_at',
        )
        read_only_fields = ('id', 'miner', 'status', 'created_at', 'updated_at', 'miner_name', 'miner_phone')

class ListingCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Listing
        fields = ('weight_grams', 'karat', 'asking_price', 'price_per_gram', 'notes', 'region', 'photo')
