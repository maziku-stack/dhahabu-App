from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError as DjangoValidationError
from .models import DealerProfile

User = get_user_model()
PRIVACY_NOTICE_VERSION = '2026-10-draft-1'


class EmailPasswordRegisterSerializer(serializers.Serializer):
    full_name = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    phone = serializers.CharField(max_length=20)
    role = serializers.ChoiceField(choices=['miner', 'dealer'])
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirmation = serializers.CharField(write_only=True)
    privacy_notice_version = serializers.CharField(max_length=32)
    privacy_notice_acknowledged = serializers.BooleanField()

    def validate_privacy_notice_acknowledged(self, value):
        if value is not True:
            raise serializers.ValidationError('Acknowledge that you have read the privacy notice.')
        return value

    def validate_privacy_notice_version(self, value):
        if value != PRIVACY_NOTICE_VERSION:
            raise serializers.ValidationError('Please read and acknowledge the current privacy notice.')
        return value

    def validate_email(self, value):
        value = value.strip().lower()
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError('An account with this email already exists.')
        return value

    def validate_phone(self, value):
        value = value.strip()
        if User.objects.filter(phone=value).exists():
            raise serializers.ValidationError('An account with this phone number already exists.')
        return value

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirmation']:
            raise serializers.ValidationError({'password_confirmation': 'Passwords do not match.'})
        try:
            validate_password(attrs['password'])
        except DjangoValidationError as error:
            raise serializers.ValidationError({'password': error.messages})
        return attrs


class EmailPasswordLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


class UserSerializer(serializers.ModelSerializer):
    dealer_verified = serializers.SerializerMethodField()
    verification_status = serializers.SerializerMethodField()
    pin_set = serializers.SerializerMethodField()

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

    def get_pin_set(self, obj):
        # Older installs stored only a flag and discarded the PIN. Require
        # those users to choose a PIN again before confirming a sale.
        return bool(obj.pin_hash)

    def get_verification_status(self, obj):
        if obj.role != 'dealer':
            return None
        try:
            return obj.dealer_profile.verification_status
        except DealerProfile.DoesNotExist:
            return 'pending'


class RequestOTPSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    # Admin accounts are provisioned by staff, never through public registration.
    role = serializers.ChoiceField(choices=['miner', 'dealer'], default='miner')
    allow_registration = serializers.BooleanField(default=True)


class VerifyOTPSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    code = serializers.CharField(max_length=6)
    full_name = serializers.CharField(max_length=150, required=False, allow_blank=True)
    role = serializers.ChoiceField(choices=['miner', 'dealer'], default='miner')
    region = serializers.CharField(max_length=100, required=False, allow_blank=True)
    mining_site = serializers.CharField(max_length=200, required=False, allow_blank=True)
    business_name = serializers.CharField(max_length=200, required=False, allow_blank=True)
    license_number = serializers.CharField(max_length=100, required=False, allow_blank=True)
    privacy_notice_version = serializers.CharField(max_length=32, required=False, allow_blank=True)
    privacy_notice_acknowledged = serializers.BooleanField(required=False, default=False)


class ProfileUpdateSerializer(serializers.ModelSerializer):
    def validate_email(self, value):
        value = value.strip().lower()
        if not value:
            return value
        if User.objects.filter(email__iexact=value).exclude(pk=self.instance.pk).exists():
            raise serializers.ValidationError('An account with this email already exists.')
        return value

    class Meta:
        model = User
        fields = ('full_name', 'email', 'region', 'mining_site', 'preferred_language')


class DealerProfileSerializer(serializers.ModelSerializer):
    owner_name = serializers.CharField(source='user.full_name', read_only=True)
    owner_phone = serializers.CharField(source='user.phone', read_only=True)

    class Meta:
        model = DealerProfile
        fields = (
            'id', 'business_name', 'owner_name', 'owner_phone',
            'license_number', 'license_document',
            'verification_status', 'rejection_reason', 'verified_at', 'created_at',
        )
        read_only_fields = ('id', 'verification_status', 'rejection_reason', 'verified_at', 'created_at')
