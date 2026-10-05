from rest_framework import serializers
from django.utils import timezone
from datetime import timedelta
from .models import GoldPrice

class GoldPriceSerializer(serializers.ModelSerializer):
    is_stale = serializers.SerializerMethodField()
    age_hours = serializers.SerializerMethodField()

    class Meta:
        model = GoldPrice
        fields = ('id', 'karat', 'price_per_gram', 'currency', 'source', 'effective_at', 'is_active', 'is_stale', 'age_hours', 'created_at')
        read_only_fields = ('id', 'created_at')

    def get_age_hours(self, obj):
        return round((timezone.now() - obj.effective_at).total_seconds() / 3600, 1)

    def get_is_stale(self, obj):
        return (timezone.now() - obj.effective_at) > timedelta(hours=6)

class GoldPriceCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = GoldPrice
        fields = ('karat', 'price_per_gram', 'currency', 'source', 'effective_at')
