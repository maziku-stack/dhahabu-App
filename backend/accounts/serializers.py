from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import DealerProfile

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    dealer_verified = serializers.SerializerMethodField()
    verification_status = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            'id', 'phone', 'email', 'full_name', 'role', 'phone_verified',
            'pin_set', 'region', 'mining_site', 'preferred_language',
            'dealer_verified', 'verification_status', 'date_joined',
        )
        read_only_fields = fields

    def get_dealer_verified(self, obj):
        if obj.role != 'dealer':
            return None
        try:
            return obj.dealer_profile.verification_status == 'verified'
        except DealerProfile.DoesNotExist:
            return False

    def get_verification_status(self, obj):
        if obj.role != 'dealer':
            return None
        try:
            return obj.dealer_profile.verification_status
        except DealerProfile.DoesNotExist:
            return 'pending'


class RequestOTPSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    role = serializers.ChoiceField(choices=['miner', 'dealer', 'admin'], default='miner')


class VerifyOTPSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    code = serializers.CharField(max_length=6)
    full_name = serializers.CharField(max_length=150, required=False, allow_blank=True)
    role = serializers.ChoiceField(choices=['miner', 'dealer', 'admin'], default='miner')
    region = serializers.CharField(max_length=100, required=False, allow_blank=True)
    mining_site = serializers.CharField(max_length=200, required=False, allow_blank=True)
    business_name = serializers.CharField(max_length=200, required=False, allow_blank=True)
    license_number = serializers.CharField(max_length=100, required=False, allow_blank=True)


class ProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('full_name', 'email', 'region', 'mining_site', 'preferred_language', 'pin_set')


class DealerProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = DealerProfile
        fields = (
            'id', 'business_name', 'license_number', 'license_document',
            'verification_status', 'rejection_reason', 'verified_at', 'created_at',
        )
        read_only_fields = ('id', 'verification_status', 'rejection_reason', 'verified_at', 'created_at')
