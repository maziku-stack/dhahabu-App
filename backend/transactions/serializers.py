from rest_framework import serializers
from decimal import Decimal
from django.contrib.auth import get_user_model
from .models import Transaction, TaxRecord

User = get_user_model()

class TaxRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = TaxRecord
        fields = ('id', 'royalty_rate', 'royalty_amount', 'tax_base', 'currency', 'created_at', 'is_reversal')

class TransactionSerializer(serializers.ModelSerializer):
    miner_name = serializers.CharField(source='miner.full_name', read_only=True)
    miner_phone = serializers.CharField(source='miner.phone', read_only=True)
    dealer_name = serializers.CharField(source='dealer.full_name', read_only=True)
    dealer_phone = serializers.CharField(source='dealer.phone', read_only=True)
    tax_record = TaxRecordSerializer(read_only=True)

    class Meta:
        model = Transaction
        fields = (
            'id', 'miner', 'dealer', 'listing', 'miner_name', 'miner_phone',
            'dealer_name', 'dealer_phone', 'weight_grams', 'karat', 'price_per_gram',
            'agreed_price', 'status', 'notes', 'created_at', 'confirmed_at',
            'client_ref', 'tax_record',
        )
        read_only_fields = ('id', 'status', 'created_at', 'confirmed_at', 'tax_record')

class CreateTransactionSerializer(serializers.Serializer):
    counterparty_phone = serializers.CharField(max_length=20)
    weight_grams = serializers.DecimalField(max_digits=10, decimal_places=3, min_value=Decimal('0.001'))
    karat = serializers.ChoiceField(choices=['24K', '22K', '18K'])
    price_per_gram = serializers.DecimalField(max_digits=12, decimal_places=2, min_value=Decimal('0.01'))
    notes = serializers.CharField(required=False, allow_blank=True)
    client_ref = serializers.CharField(required=False, allow_blank=True, max_length=64)
    listing_id = serializers.UUIDField(required=False, allow_null=True)

    def validate_counterparty_phone(self, value):
        try:
            return User.objects.get(phone=value.strip(), is_active=True)
        except User.DoesNotExist:
            raise serializers.ValidationError('User not found.')
