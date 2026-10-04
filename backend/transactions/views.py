from decimal import Decimal
from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q, Sum
from django.utils import timezone
from .models import Transaction, TaxRecord, AuditLog
from .serializers import (
    TransactionSerializer, CreateTransactionSerializer, TaxRecordSerializer,
)


def log_audit(actor, action, entity_type, entity_id, payload=None, request=None):
    ip = None
    if request:
        ip = request.META.get('HTTP_X_FORWARDED_FOR', request.META.get('REMOTE_ADDR'))
    AuditLog.objects.create(
        actor=actor, action=action, entity_type=entity_type,
        entity_id=str(entity_id), payload=payload or {}, ip_address=ip,
    )


class CreateTransactionView(APIView):
    """Miner or Dealer initiates a sale record."""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        ser = CreateTransactionSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        data = ser.validated_data
        counterparty = data['counterparty_phone']  # User instance
        user = request.user

        # Determine miner vs dealer roles
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

        # Idempotency for offline sync
        client_ref = data.get('client_ref', '')
        if client_ref:
            existing = Transaction.objects.filter(client_ref=client_ref, created_by=user).first()
            if existing:
                return Response(TransactionSerializer(existing).data, status=200)

        txn = Transaction.objects.create(
            miner=miner,
            dealer=dealer,
            weight_grams=weight,
            karat=data['karat'],
            price_per_gram=price_pg,
            agreed_price=agreed,
            notes=data.get('notes', ''),
            status='pending_confirm',
            created_by=user,
            client_ref=client_ref,
            synced_at=timezone.now() if client_ref else None,
        )
        log_audit(user, 'transaction.created', 'Transaction', txn.id, {
            'weight': str(weight), 'karat': data['karat'], 'agreed_price': str(agreed),
        }, request)

        return Response(TransactionSerializer(txn).data, status=201)


class ConfirmTransactionView(APIView):
    """Miner confirms the sale → locks record + creates TaxRecord."""
    permission_classes = [IsAuthenticated]

    def post(self, request, txn_id):
        try:
            txn = Transaction.objects.select_related('miner', 'dealer').get(id=txn_id)
        except Transaction.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=404)

        # Only the miner can confirm
        if request.user.id != txn.miner_id and request.user.role != 'admin':
            return Response({'detail': 'Only the miner can confirm this sale.'}, status=403)
        if txn.status == 'confirmed':
            return Response(TransactionSerializer(txn).data)
        if txn.status == 'cancelled':
            return Response({'detail': 'Transaction was cancelled.'}, status=400)

        txn.confirm()
        log_audit(request.user, 'transaction.confirmed', 'Transaction', txn.id, {
            'agreed_price': str(txn.agreed_price),
            'royalty': str(txn.tax_record.royalty_amount) if hasattr(txn, 'tax_record') else None,
        }, request)
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
        status_filter = self.request.query_params.get('status')
        if status_filter:
            qs = qs.filter(status=status_filter)
        return qs.select_related('miner', 'dealer').prefetch_related('tax_record')


class TransactionDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = TransactionSerializer
    queryset = Transaction.objects.select_related('miner', 'dealer').prefetch_related('tax_record')

    def get_object(self):
        obj = super().get_object()
        user = self.request.user
        if user.role != 'admin' and not user.is_staff:
            if user.id not in (obj.miner_id, obj.dealer_id):
                from rest_framework.exceptions import PermissionDenied
                raise PermissionDenied()
        return obj


class AdminDashboardView(APIView):
    """Government admin summary: volume, royalty due, tax collected."""
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
            transaction__in=confirmed, is_reversal=False,
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
