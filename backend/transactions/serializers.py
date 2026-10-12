from rest_framework import serializers
from decimal import Decimal
from django.contrib.auth import get_user_model
from .models import Transaction, TaxRecord, GovernmentCharge

User = get_user_model()

class GovernmentChargeSerializer(serializers.ModelSerializer):
    class Meta:
        model = GovernmentCharge
        fields = ('id', 'authority', 'charge_code', 'charge_name', 'legal_basis', 'payer_role', 'calculation_rate', 'calculation_basis', 'amount', 'currency', 'assessment_status', 'assessment_reference', 'payment_status', 'payment_reference', 'assessed_at', 'paid_at')


class TaxRecordSerializer(serializers.ModelSerializer):
    charges = GovernmentChargeSerializer(many=True, read_only=True)
    royalty_rate = serializers.SerializerMethodField()
    royalty_amount = serializers.SerializerMethodField()
    tax_base = serializers.SerializerMethodField()

    def get_royalty_rate(self, obj):
        return obj.royalty_rate if obj.assessment_status == 'assessed' else None

    def get_royalty_amount(self, obj):
        return obj.royalty_amount if obj.assessment_status == 'assessed' else None

    def get_tax_base(self, obj):
        return obj.tax_base if obj.assessment_status == 'assessed' else None

    class Meta:
        model = TaxRecord
        fields = ('id', 'royalty_rate', 'royalty_amount', 'tax_base', 'currency', 'created_at', 'is_reversal', 'assessment_status', 'authority', 'authority_reference', 'payment_status', 'payment_reference', 'charges')

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
            'agreed_price', 'price_basis', 'assay_status', 'assay_reference', 'measured_weight_grams', 'measured_karat', 'measured_purity', 'assay_device_id', 'assayed_at', 'status', 'notes', 'created_at', 'confirmed_at',
            'miner_confirmed_at', 'dealer_confirmed_at', 'client_ref', 'tax_record',
        )
        read_only_fields = (
            'id', 'status', 'created_at', 'confirmed_at',
            'miner_confirmed_at', 'dealer_confirmed_at', 'tax_record', 'price_basis',
            'assay_status', 'assay_reference', 'measured_weight_grams', 'measured_karat',
            'measured_purity', 'assay_device_id', 'assayed_at',
        )

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
