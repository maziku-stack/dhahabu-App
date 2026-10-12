from decimal import Decimal
from django.contrib.auth.hashers import check_password
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics
from django.db.models import Q, Sum
from django.db import transaction as db_transaction
from django.utils import timezone
from django.conf import settings
from accounts.models import DealerProfile
from .models import Transaction, TaxRecord, AuditLog, GovernmentCharge
from .serializers import TransactionSerializer, CreateTransactionSerializer, TaxRecordSerializer

def audit(actor, action, entity_type, entity_id, payload=None):
    AuditLog.objects.create(
        actor=actor, action=action, entity_type=entity_type,
        entity_id=str(entity_id), payload=payload or {},
    )

class CreateTransactionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        ser = CreateTransactionSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        data = ser.validated_data
        counterparty = data['counterparty_phone']
        user = request.user

        if user.role == 'miner':
            miner, dealer = user, counterparty
            if counterparty.role != 'dealer':
                return Response({'detail': 'Counterparty must be a dealer.'}, status=400)
        elif user.role == 'dealer':
            miner, dealer = counterparty, user
            if counterparty.role != 'miner':
                return Response({'detail': 'Counterparty must be a miner.'}, status=400)
        else:
            return Response({'detail': 'Only miners and dealers can create transactions.'}, status=403)

        if miner.id == dealer.id:
            return Response({'detail': 'You cannot transact with your own account.'}, status=400)

        try:
            if dealer.dealer_profile.verification_status != 'verified':
                return Response({'detail': 'Dealer not verified. Cannot transact.'}, status=403)
        except DealerProfile.DoesNotExist:
            return Response({'detail': 'Dealer profile missing or not verified.'}, status=403)

        weight = data['weight_grams']
        price_pg = data['price_per_gram']
        agreed = (weight * price_pg).quantize(Decimal('0.01'))
        client_ref = data.get('client_ref', '')
        if client_ref:
            existing = Transaction.objects.filter(client_ref=client_ref, created_by=user).first()
            if existing:
                return Response(TransactionSerializer(existing).data)

        listing = None
        lid = data.get('listing_id')
        if lid:
            from listings.models import Listing
            listing = Listing.objects.filter(id=lid).first()
            if listing is None:
                return Response({'detail': 'Listing not found.'}, status=404)
            if listing.status != 'open':
                return Response({'detail': 'This listing is no longer open.'}, status=409)
            if listing.miner_id != miner.id:
                return Response({'detail': 'The listing owner must be the miner in this sale.'}, status=400)
            if listing.weight_grams != weight or listing.karat != data['karat']:
                return Response({'detail': 'Sale weight and karat must match the listing.'}, status=400)

        txn = Transaction.objects.create(
            miner=miner, dealer=dealer, listing=listing,
            weight_grams=weight, karat=data['karat'], price_per_gram=price_pg,
            agreed_price=agreed, notes=data.get('notes', ''),
            status='pending_confirm', created_by=user, client_ref=client_ref,
            synced_at=timezone.now() if client_ref else None,
        )
        audit(user, 'transaction.created', 'Transaction', txn.id, {'agreed_price': str(agreed)})
        return Response(TransactionSerializer(txn).data, status=201)

class ConfirmTransactionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, txn_id):
        with db_transaction.atomic():
            try:
                txn = Transaction.objects.select_for_update().select_related(
                    'miner', 'dealer'
                ).get(id=txn_id)
            except Transaction.DoesNotExist:
                return Response({'detail': 'Not found.'}, status=404)
            if request.user.id not in (txn.miner_id, txn.dealer_id):
                return Response({'detail': 'Only the miner or dealer in this sale can confirm it.'}, status=403)
            if txn.status == 'confirmed':
                return Response(TransactionSerializer(txn).data)
            if txn.status != 'pending_confirm':
                return Response({'detail': f'Transaction is {txn.status} and cannot be confirmed.'}, status=400)
            accepted_field = (
                'miner_confirmed_at'
                if request.user.id == txn.miner_id
                else 'dealer_confirmed_at'
            )
            if getattr(txn, accepted_field):
                return Response(TransactionSerializer(txn).data)
            pin = str(request.data.get('pin', '')).strip()
            if not request.user.pin_hash or not check_password(pin, request.user.pin_hash):
                return Response({'detail': 'A valid account PIN is required to confirm this sale.'}, status=400)

            if txn.listing_id:
                from listings.models import Listing
                listing = Listing.objects.select_for_update().get(id=txn.listing_id)
                if listing.status != 'open':
                    txn.status = 'rejected_conflict'
                    txn.save(update_fields=['status'])
                    return Response({'detail': 'This listing was already sold or closed.'}, status=409)

            setattr(txn, accepted_field, timezone.now())
            txn.save(update_fields=[accepted_field])
            audit(request.user, 'transaction.party_confirmed', 'Transaction', txn.id, {
                'party': 'miner' if request.user.id == txn.miner_id else 'dealer',
            })

            if txn.miner_confirmed_at and txn.dealer_confirmed_at:
                txn.confirm()
                audit(request.user, 'transaction.confirmed', 'Transaction', txn.id, {
                    'government_charge_assessment': 'unavailable_until_authority_api_connected',
                    'government_payment': 'not_started',
                })
            return Response(TransactionSerializer(txn).data)

class MyTransactionsView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = TransactionSerializer

    def get_queryset(self):
        user = self.request.user
        if user.role == 'admin' or user.is_staff:
            qs = Transaction.objects.all()
        else:
            qs = Transaction.objects.filter(Q(miner=user) | Q(dealer=user))
        st = self.request.query_params.get('status')
        if st:
            qs = qs.filter(status=st)
        return qs.select_related('miner', 'dealer').prefetch_related('tax_record__charges')

class TransactionDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = TransactionSerializer
    lookup_url_kwarg = 'txn_id'
    def get_queryset(self):
        user = self.request.user
        qs = Transaction.objects.select_related('miner', 'dealer').prefetch_related('tax_record__charges')
        if user.role == 'admin' or user.is_staff:
            return qs
        return qs.filter(Q(miner=user) | Q(dealer=user))

class TaxSummaryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        if user.role not in ('dealer', 'admin') and not user.is_staff:
            return Response({'detail': 'Dealers only.'}, status=403)
        qs = TaxRecord.objects.filter(is_reversal=False)
        if user.role == 'dealer':
            qs = qs.filter(transaction__dealer=user)
        charge_qs = GovernmentCharge.objects.filter(assessment_status='assessed')
        if user.role == 'dealer':
            charge_qs = charge_qs.filter(tax_record__transaction__dealer=user)
        total_charges = charge_qs.aggregate(s=Sum('amount'))['s'] or 0
        count = qs.count()
        return Response({
            'transaction_count': count,
            'total_assessed_charges_tzs': str(total_charges),
            'total_royalty_tzs': str(total_charges),  # compatibility key; value means assessed charges
            'assessment_status': 'configured_pending_assessments' if settings.DH_CHARGE_ASSESSMENT_PROVIDER else 'unavailable_until_authority_api_connected',
            'records': TaxRecordSerializer(qs.prefetch_related('charges').order_by('-created_at')[:50], many=True).data,
        })

class AdminDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != 'admin' and not request.user.is_staff:
            return Response({'detail': 'Admin only.'}, status=403)
        confirmed = Transaction.objects.filter(status='confirmed')
        region = request.query_params.get('region')
        if region:
            confirmed = confirmed.filter(miner__region__icontains=region)
        totals = confirmed.aggregate(
            total_volume_grams=Sum('weight_grams'),
            total_value=Sum('agreed_price'),
        )
        tax_totals = GovernmentCharge.objects.filter(
            tax_record__transaction__in=confirmed, assessment_status='assessed'
        ).aggregate(total_charges=Sum('amount'))
        recent = confirmed.select_related('miner', 'dealer').order_by('-confirmed_at')[:20]
        return Response({
            'summary': {
                'transaction_count': confirmed.count(),
                'total_volume_grams': str(totals['total_volume_grams'] or 0),
                'total_value_tzs': str(totals['total_value'] or 0),
                'total_assessed_charges_tzs': str(tax_totals['total_charges'] or 0),
                'total_royalty_tzs': str(tax_totals['total_charges'] or 0),
            },
            'recent_transactions': TransactionSerializer(recent, many=True).data,
        })

class AuditLogListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != 'admin' and not request.user.is_staff:
            return Response({'detail': 'Admin only.'}, status=403)
        logs = AuditLog.objects.select_related('actor')[:100]
        data = [{
            'id': str(l.id),
            'action': l.action,
            'entity_type': l.entity_type,
            'entity_id': l.entity_id,
            'actor': l.actor.phone if l.actor else None,
            'payload': l.payload,
            'created_at': l.created_at.isoformat(),
        } for l in logs]
        return Response(data)
