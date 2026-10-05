from decimal import Decimal
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics
from django.db.models import Q, Sum
from django.utils import timezone
from .models import Transaction, TaxRecord, AuditLog
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

        if user.role == 'dealer':
            try:
                if user.dealer_profile.verification_status != 'verified':
                    return Response({'detail': 'Dealer not verified. Cannot transact.'}, status=403)
            except Exception:
                return Response({'detail': 'Dealer profile missing or not verified.'}, status=403)

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
        try:
            txn = Transaction.objects.select_related('miner', 'dealer').get(id=txn_id)
        except Transaction.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=404)
        if request.user.id != txn.miner_id and request.user.role != 'admin':
            return Response({'detail': 'Only the miner can confirm this sale.'}, status=403)
        if txn.status == 'confirmed':
            return Response(TransactionSerializer(txn).data)
        if txn.status == 'cancelled':
            return Response({'detail': 'Cancelled.'}, status=400)
        txn.confirm()
        audit(request.user, 'transaction.confirmed', 'Transaction', txn.id, {
            'royalty': str(txn.tax_record.royalty_amount) if hasattr(txn, 'tax_record') else None,
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
        return qs.select_related('miner', 'dealer').prefetch_related('tax_record')

class TransactionDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = TransactionSerializer
    queryset = Transaction.objects.select_related('miner', 'dealer').prefetch_related('tax_record')

class TaxSummaryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        if user.role not in ('dealer', 'admin') and not user.is_staff:
            return Response({'detail': 'Dealers only.'}, status=403)
        qs = TaxRecord.objects.filter(is_reversal=False)
        if user.role == 'dealer':
            qs = qs.filter(transaction__dealer=user)
        total = qs.aggregate(s=Sum('royalty_amount'))['s'] or 0
        count = qs.count()
        return Response({
            'transaction_count': count,
            'total_royalty_tzs': str(total),
            'records': TaxRecordSerializer(qs.order_by('-created_at')[:50], many=True).data,
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
        tax_totals = TaxRecord.objects.filter(
            transaction__in=confirmed, is_reversal=False
        ).aggregate(total_royalty=Sum('royalty_amount'))
        recent = confirmed.select_related('miner', 'dealer').order_by('-confirmed_at')[:20]
        return Response({
            'summary': {
                'transaction_count': confirmed.count(),
                'total_volume_grams': str(totals['total_volume_grams'] or 0),
                'total_value_tzs': str(totals['total_value'] or 0),
                'total_royalty_tzs': str(tax_totals['total_royalty'] or 0),
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
