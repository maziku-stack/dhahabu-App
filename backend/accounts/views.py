import secrets
from datetime import timedelta
from django.conf import settings
from django.utils import timezone
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password, make_password
from django.db import transaction
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework import generics
from rest_framework_simplejwt.tokens import RefreshToken
from .models import OTPCode, DealerProfile, PrivacyRequest
from .serializers import (
    RequestOTPSerializer, VerifyOTPSerializer, UserSerializer,
    ProfileUpdateSerializer, DealerProfileSerializer,
    EmailPasswordRegisterSerializer, EmailPasswordLoginSerializer,
    PRIVACY_NOTICE_VERSION,
)

User = get_user_model()


def tokens_for(user):
    refresh = RefreshToken.for_user(user)
    return {'refresh': str(refresh), 'access': str(refresh.access_token)}


class EmailPasswordRegisterView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def post(self, request):
        ser = EmailPasswordRegisterSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        data = ser.validated_data
        user = User.objects.create_user(
            phone=data['phone'],
            password=data['password'],
            email=data['email'],
            full_name=data['full_name'].strip(),
            role=data['role'],
            privacy_notice_version=data['privacy_notice_version'],
            privacy_acknowledged_at=timezone.now(),
        )
        if user.role == 'dealer':
            DealerProfile.objects.create(
                user=user,
                business_name=user.full_name or user.email.split('@')[0],
            )
        tokens = tokens_for(user)
        return Response({
            'user': UserSerializer(user).data,
            'access': tokens['access'],
            'refresh': tokens['refresh'],
        }, status=201)


class EmailPasswordLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        ser = EmailPasswordLoginSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        email = ser.validated_data['email'].strip()
        user = User.objects.filter(email__iexact=email).first()
        if user is None or not user.is_active or not check_password(
            ser.validated_data['password'], user.password
        ):
            return Response({'detail': 'Invalid email or password.'}, status=400)
        tokens = tokens_for(user)
        return Response({
            'user': UserSerializer(user).data,
            'access': tokens['access'],
            'refresh': tokens['refresh'],
        })


class RequestOTPView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        ser = RequestOTPSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        phone = ser.validated_data['phone'].strip()

        if (
            not ser.validated_data['allow_registration']
            and not User.objects.filter(phone=phone).exists()
        ):
            return Response(
                {'detail': 'No account found for this phone number. Create an account first.'},
                status=404,
            )

        locked = OTPCode.objects.filter(
            phone=phone, locked_until__gt=timezone.now()
        ).first()
        if locked:
            return Response({'detail': 'Too many attempts. Try later.'}, status=429)

        recent = OTPCode.objects.filter(
            phone=phone, created_at__gte=timezone.now() - timedelta(hours=1)
        ).count()
        if recent >= 5:
            return Response({'detail': 'Too many OTP requests.'}, status=429)

        code = '123456' if settings.MOCK_OTP else f'{secrets.randbelow(900000) + 100000}'
        OTPCode.objects.create(
            phone=phone, code=code,
            expires_at=timezone.now() + timedelta(minutes=5),
        )
        payload = {'detail': 'OTP sent', 'phone': phone}
        if settings.MOCK_OTP:
            payload['mock_otp'] = code
        return Response(payload)


class VerifyOTPView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def post(self, request):
        ser = VerifyOTPSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        data = ser.validated_data
        phone = data['phone'].strip()
        code = data['code'].strip()

        otp = OTPCode.objects.select_for_update().filter(
            phone=phone, is_used=False, expires_at__gte=timezone.now()
        ).order_by('-created_at').first()
        if not otp:
            return Response({'detail': 'OTP expired or not found.'}, status=400)
        if not User.objects.filter(phone=phone).exists() and (
            data.get('privacy_notice_version') != PRIVACY_NOTICE_VERSION
            or data.get('privacy_notice_acknowledged') is not True
        ):
            return Response({'detail': 'Please read and acknowledge the current privacy notice before creating an account.'}, status=400)
        if otp.attempts >= 3:
            otp.locked_until = timezone.now() + timedelta(minutes=15)
            otp.save(update_fields=['locked_until'])
            return Response({'detail': 'Too many incorrect attempts. Locked 15 minutes.'}, status=400)
        if otp.code != code:
            otp.attempts += 1
            otp.save(update_fields=['attempts'])
            return Response({'detail': 'Invalid OTP.'}, status=400)

        otp.is_used = True
        otp.save(update_fields=['is_used'])

        role = data.get('role', 'miner')
        user, created = User.objects.get_or_create(
            phone=phone,
            defaults={
                'role': role,
                'full_name': data.get('full_name', ''),
                'region': data.get('region', ''),
                'mining_site': data.get('mining_site', ''),
                'phone_verified': True,
                'privacy_notice_version': data.get('privacy_notice_version', ''),
                'privacy_acknowledged_at': timezone.now(),
            },
        )
        if not created:
            user.phone_verified = True
            if data.get('full_name'):
                user.full_name = data['full_name']
            if data.get('region'):
                user.region = data['region']
            if data.get('mining_site'):
                user.mining_site = data['mining_site']
            user.save()

        # The requested role is only used when creating an account. Never let
        # OTP verification change an existing account's privileges or role.
        if user.role == 'dealer':
            DealerProfile.objects.get_or_create(
                user=user,
                defaults={
                    'business_name': data.get('business_name') or f'Dealer {phone}',
                    'license_number': data.get('license_number', ''),
                },
            )

        t = tokens_for(user)
        return Response({
            'user': UserSerializer(user).data,
            'access': t['access'],
            'refresh': t['refresh'],
            'is_new': created,
        })


class MeView(generics.RetrieveUpdateAPIView):
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user

    def get_serializer_class(self):
        if self.request.method in ('PUT', 'PATCH'):
            return ProfileUpdateSerializer
        return UserSerializer


class DealerProfileView(generics.RetrieveUpdateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = DealerProfileSerializer

    def get_object(self):
        if self.request.user.role != 'dealer':
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied('Dealer accounts only.')
        profile, _ = DealerProfile.objects.get_or_create(
            user=self.request.user,
            defaults={'business_name': self.request.user.full_name or 'My Business'},
        )
        return profile


class PendingDealersView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = DealerProfileSerializer

    def get_queryset(self):
        if self.request.user.role != 'admin' and not self.request.user.is_staff:
            return DealerProfile.objects.none()
        return DealerProfile.objects.filter(verification_status='pending').select_related('user')


class AdminVerifyDealerView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, dealer_id):
        if request.user.role != 'admin' and not request.user.is_staff:
            return Response({'detail': 'Admin only.'}, status=403)
        try:
            profile = DealerProfile.objects.get(id=dealer_id)
        except DealerProfile.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=404)
        action = request.data.get('action', 'approve')
        if action not in ('approve', 'reject'):
            return Response({'detail': 'Action must be approve or reject.'}, status=400)
        if action == 'approve':
            profile.verification_status = 'verified'
            profile.verified_at = timezone.now()
            profile.rejection_reason = ''
        else:
            profile.verification_status = 'rejected'
            profile.rejection_reason = request.data.get('reason', 'Incomplete documents')
        profile.save()
        return Response(DealerProfileSerializer(profile).data)


class SetPinView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        pin = str(request.data.get('pin', '')).strip()
        if not pin.isdigit() or not 4 <= len(pin) <= 6:
            return Response({'detail': 'PIN must contain 4 to 6 digits.'}, status=400)
        request.user.pin_set = True
        request.user.pin_hash = make_password(pin)
        request.user.save(update_fields=['pin_set', 'pin_hash'])
        return Response({'detail': 'PIN set', 'pin_set': True})
