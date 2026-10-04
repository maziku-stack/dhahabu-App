import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from django.utils import timezone


class Transaction(models.Model):
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('pending_confirm', 'Pending Miner Confirm'),
        ('confirmed', 'Confirmed'),
        ('cancelled', 'Cancelled'),
    ]
    KARAT_CHOICES = [('24K', '24K'), ('22K', '22K'), ('18K', '18K')]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    miner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT,
        related_name='sales_as_miner',
    )
    dealer = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT,
        related_name='purchases_as_dealer',
    )
    weight_grams = models.DecimalField(max_digits=10, decimal_places=3)
    karat = models.CharField(max_length=5, choices=KARAT_CHOICES)
    price_per_gram = models.DecimalField(max_digits=12, decimal_places=2)
    agreed_price = models.DecimalField(max_digits=14, decimal_places=2)  # total TZS
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending_confirm')
    notes = models.TextField(blank=True)
    # Server-assigned timestamps only (never trust client for audit)
    created_at = models.DateTimeField(auto_now_add=True)
    confirmed_at = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT,
        related_name='transactions_created',
    )
    # Offline sync support
    client_ref = models.CharField(max_length=64, blank=True, db_index=True)  # client offline id
    synced_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'transactions'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['miner', '-created_at']),
            models.Index(fields=['dealer', '-created_at']),
            models.Index(fields=['status', '-created_at']),
        ]

    def __str__(self):
        return f'TXN {self.id} {self.weight_grams}g {self.karat} → {self.agreed_price}'

    def confirm(self):
        if self.status == 'confirmed':
            return
        self.status = 'confirmed'
        self.confirmed_at = timezone.now()
        self.save(update_fields=['status', 'confirmed_at'])
        # Auto-create tax record
        TaxRecord.create_for_transaction(self)


class TaxRecord(models.Model):
    """Immutable tax/royalty record. Corrections require a linked reversal."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    transaction = models.OneToOneField(
        Transaction, on_delete=models.PROTECT, related_name='tax_record',
    )
    royalty_rate = models.DecimalField(max_digits=5, decimal_places=4)  # e.g. 0.0700
    royalty_amount = models.DecimalField(max_digits=14, decimal_places=2)
    tax_base = models.DecimalField(max_digits=14, decimal_places=2)  # agreed_price
    currency = models.CharField(max_length=5, default='TZS')
    created_at = models.DateTimeField(auto_now_add=True)
    # Reversal support
    is_reversal = models.BooleanField(default=False)
    reverses = models.ForeignKey(
        'self', null=True, blank=True, on_delete=models.PROTECT,
        related_name='reversed_by',
    )

    class Meta:
        db_table = 'tax_records'
        ordering = ['-created_at']

    def __str__(self):
        return f'Tax {self.royalty_amount} on TXN {self.transaction_id}'

    @classmethod
    def create_for_transaction(cls, txn):
        if hasattr(txn, 'tax_record'):
            return txn.tax_record
        rate = Decimal(str(settings.DEFAULT_ROYALTY_RATE))
        amount = (txn.agreed_price * rate).quantize(Decimal('0.01'))
        return cls.objects.create(
            transaction=txn,
            royalty_rate=rate,
            royalty_amount=amount,
            tax_base=txn.agreed_price,
        )


class AuditLog(models.Model):
    """Immutable audit trail for every important action."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    actor = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL,
        related_name='audit_actions',
    )
    action = models.CharField(max_length=50)  # e.g. transaction.confirmed
    entity_type = models.CharField(max_length=50)
    entity_id = models.CharField(max_length=64)
    payload = models.JSONField(default=dict)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'audit_logs'
        ordering = ['-created_at']
