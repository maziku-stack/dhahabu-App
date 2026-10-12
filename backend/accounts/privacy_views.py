from django.utils import timezone
from rest_framework import serializers
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from listings.models import Listing
from transactions.models import TaxRecord, Transaction
from feedback.models import Feedback
from .models import DealerProfile, PrivacyRequest


def _tax_export(transaction):
    try:
        record = transaction.tax_record
    except TaxRecord.DoesNotExist:
        return None
    return {
        'authority': record.authority,
        'authority_reference': record.authority_reference,
        'assessment_status': record.assessment_status,
        'payment_status': record.payment_status,
        'payment_reference': record.payment_reference,
        'charges': [{
            'authority': charge.authority,
            'charge_code': charge.charge_code,
            'charge_name': charge.charge_name,
            'amount': str(charge.amount) if charge.amount is not None else None,
            'currency': charge.currency,
            'assessment_status': charge.assessment_status,
            'payment_status': charge.payment_status,
            'payment_reference': charge.payment_reference,
        } for charge in record.charges.all()],
    }


class PrivacyRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = PrivacyRequest
        fields = ('id', 'request_type', 'details', 'status', 'created_at', 'updated_at')
        read_only_fields = ('id', 'status', 'created_at', 'updated_at')


class PrivacyExportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        listings = Listing.objects.filter(miner=user).order_by('created_at')
        transactions = Transaction.objects.filter(miner=user) | Transaction.objects.filter(dealer=user)
        export = {
            'exported_at': timezone.now().isoformat(),
            'profile': {
                'id': str(user.pk), 'full_name': user.full_name, 'email': user.email,
                'phone': user.phone, 'role': user.role, 'phone_verified': user.phone_verified,
                'region': user.region, 'mining_site': user.mining_site,
                'preferred_language': user.preferred_language,
                'joined_at': user.date_joined.isoformat(),
            },
            'listings': [{
                'id': str(item.pk), 'weight_grams': str(item.weight_grams), 'karat': item.karat,
                'asking_price': str(item.asking_price), 'status': item.status,
                'region': item.region, 'notes': item.notes,
                'photo': item.photo.name if item.photo else None,
                'created_at': item.created_at.isoformat(),
            } for item in listings],
            'transactions': [{
                'id': str(item.pk), 'your_role': 'miner' if item.miner_id == user.pk else 'dealer',
                'counterparty_name': item.dealer.full_name if item.miner_id == user.pk else item.miner.full_name,
                'weight_grams': str(item.weight_grams), 'karat': item.karat,
                'agreed_price': str(item.agreed_price), 'status': item.status,
                'assay_status': item.assay_status,
                'measured_weight_grams': str(item.measured_weight_grams) if item.measured_weight_grams is not None else None,
                'measured_karat': item.measured_karat,
                'measured_purity': str(item.measured_purity) if item.measured_purity is not None else None,
                'notes': item.notes,
                'created_at': item.created_at.isoformat(),
                'confirmed_at': item.confirmed_at.isoformat() if item.confirmed_at else None,
                'tax_record': _tax_export(item),
            } for item in transactions.select_related('miner', 'dealer').order_by('created_at')],
            'dealer_profile': None,
            'feedback_and_grievances': [{
                'id': str(item.pk), 'type': item.type, 'subject': item.subject,
                'body': item.body, 'status': item.status,
                'admin_response': item.admin_response, 'region': item.region,
                'created_at': item.created_at.isoformat(),
                'updated_at': item.updated_at.isoformat(),
            } for item in Feedback.objects.filter(submitter=user).order_by('created_at')],
            'privacy_notice': {
                'version': user.privacy_notice_version,
                'acknowledged_at': user.privacy_acknowledged_at.isoformat() if user.privacy_acknowledged_at else None,
            },
            'privacy_requests': [{
                'id': str(item.pk), 'request_type': item.request_type,
                'details': item.details, 'status': item.status,
                'created_at': item.created_at.isoformat(),
                'updated_at': item.updated_at.isoformat(),
            } for item in PrivacyRequest.objects.filter(user=user).order_by('created_at')],
        }
        if user.role == 'dealer':
            try:
                dealer = user.dealer_profile
                export['dealer_profile'] = {
                    'business_name': dealer.business_name,
                    'license_number': dealer.license_number,
                    'has_license_document': bool(dealer.license_document),
                    'verification_status': dealer.verification_status,
                    'rejection_reason': dealer.rejection_reason,
                    'verified_at': dealer.verified_at.isoformat() if dealer.verified_at else None,
                    'created_at': dealer.created_at.isoformat(),
                }
            except DealerProfile.DoesNotExist:
                pass
        response = Response(export)
        response['Cache-Control'] = 'no-store, private'
        response['Pragma'] = 'no-cache'
        return response


class PrivacyRequestListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        data = PrivacyRequestSerializer(
            PrivacyRequest.objects.filter(user=request.user), many=True
        ).data
        response = Response(data)
        response['Cache-Control'] = 'no-store, private'
        return response

    def post(self, request):
        serializer = PrivacyRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        item = serializer.save(user=request.user)
        return Response(PrivacyRequestSerializer(item).data, status=201,
                        headers={'Cache-Control': 'no-store, private'})
