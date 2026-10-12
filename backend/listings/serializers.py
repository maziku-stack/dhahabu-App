from rest_framework import serializers
from .models import Listing

class ListingSerializer(serializers.ModelSerializer):
    miner_phone = serializers.SerializerMethodField()

    def get_miner_phone(self, obj):
        request = self.context.get('request')
        viewer = getattr(request, 'user', None)
        if obj.share_phone and getattr(viewer, 'is_authenticated', False):
            return obj.miner.phone
        return None

    class Meta:
        model = Listing
        fields = (
            'id', 'miner_phone', 'weight_grams', 'karat',
            'asking_price', 'price_per_gram', 'notes', 'region', 'status',
            'photo', 'share_phone', 'created_at', 'updated_at',
        )
        read_only_fields = ('id', 'status', 'created_at', 'updated_at', 'miner_phone', 'share_phone')

class ListingCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Listing
        fields = ('weight_grams', 'karat', 'asking_price', 'price_per_gram', 'notes', 'region', 'photo', 'share_phone')
