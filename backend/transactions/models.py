import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from django.utils import timezone

class Transaction(models.Model):
    STATUS = [
        ('pending_confirm', 'Pending Confirm'),
        ('confirmed', 'Confirmed'),
        ('cancelled', 'Cancelled'),
        ('rejected_conflict', 'Rejected Conflict'),
    ]
    KARAT = [('24K', '24K'), ('22K', '22K'), ('18K', '18K')]
    ASSAY_STATUS = [('unverified', 'Unverified'), ('verified', 'Authority/device verified')]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    miner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='sales_as_miner')
    dealer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='purchases_as_dealer')
    listing = models.ForeignKey('listings.Listing', null=True, blank=True, on_delete=models.SET_NULL, related_name='transactions')
    weight_grams = models.DecimalField(max_digits=10, decimal_places=3)
    karat = models.CharField(max_length=5, choices=KARAT)
    price_per_gram = models.DecimalField(max_digits=12, decimal_places=2)
    agreed_price = models.DecimalField(max_digits=14, decimal_places=2)
    price_basis = models.CharField(max_length=24, default='party_agreed')
    assay_status = models.CharField(max_length=16, choices=ASSAY_STATUS, default='unverified')
    assay_reference = models.CharField(max_length=128, blank=True)
    measured_weight_grams = models.DecimalField(max_digits=10, decimal_places=3, null=True, blank=True)
    measured_karat = models.CharField(max_length=5, choices=KARAT, blank=True)
    measured_purity = models.DecimalField(max_digits=7, decimal_places=4, null=True, blank=True)
    assay_device_id = models.CharField(max_length=128, blank=True)
    assayed_at = models.DateTimeField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS, default='pending_confirm')
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    confirmed_at = models.DateTimeField(null=True, blank=True)
    miner_confirmed_at = models.DateTimeField(null=True, blank=True)
    dealer_confirmed_at = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='transactions_created')
    client_ref = models.CharField(max_length=64, blank=True, db_index=True)
    synced_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'transactions'
        ordering = ['-created_at']

    def confirm(self):
        if self.status == 'confirmed':
            return
        if not self.miner_confirmed_at or not self.dealer_confirmed_at:
            raise ValueError('Both miner and dealer must confirm the transaction.')
        self.status = 'confirmed'
        self.confirmed_at = timezone.now()
        self.save(update_fields=['status', 'confirmed_at'])
        TaxRecord.create_for_transaction(self)
        if self.listing_id:
            self.listing.status = 'sold'
            self.listing.save(update_fields=['status', 'updated_at'])


class TaxRecord(models.Model):
    ASSESSMENT_STATUS = [('unavailable', 'Authority assessment unavailable'), ('assessed', 'Assessed')]
    PAYMENT_STATUS = [('not_started', 'Not started'), ('pending', 'Pending'), ('paid', 'Paid'), ('failed', 'Failed')]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    transaction = models.OneToOneField(Transaction, on_delete=models.PROTECT, related_name='tax_record')
    # Null until the competent authority returns its charge schedule and assessment.
    royalty_rate = models.DecimalField(max_digits=5, decimal_places=4, null=True, blank=True)
    royalty_amount = models.DecimalField(max_digits=14, decimal_places=2, null=True, blank=True)
    tax_base = models.DecimalField(max_digits=14, decimal_places=2, null=True, blank=True)
    currency = models.CharField(max_length=5, default='TZS')
    assessment_status = models.CharField(max_length=16, choices=ASSESSMENT_STATUS, default='unavailable')
    authority = models.CharField(max_length=40, blank=True)
    authority_reference = models.CharField(max_length=128, blank=True)
    payment_status = models.CharField(max_length=16, choices=PAYMENT_STATUS, default='not_started')
    payment_reference = models.CharField(max_length=128, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    is_reversal = models.BooleanField(default=False)

    class Meta:
        db_table = 'tax_records'

    @classmethod
    def create_for_transaction(cls, txn):
        if hasattr(txn, 'tax_record'):
            try:
                return txn.tax_record
            except TaxRecord.DoesNotExist:
                pass
        return cls.objects.create(
            transaction=txn,
            assessment_status='unavailable',
            payment_status='not_started',
        )


class GovernmentCharge(models.Model):
    """One separately assessed statutory charge payable to its named authority."""
    AUTHORITY = [('TRA', 'TRA'), ('MINING_COMMISSION', 'Mining Commission'), ('OTHER', 'Other government authority')]
    STATUS = [('unavailable', 'Unavailable'), ('assessed', 'Assessed')]
    PAYMENT_STATUS = [('not_started', 'Not started'), ('pending', 'Pending'), ('paid', 'Paid'), ('failed', 'Failed')]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    tax_record = models.ForeignKey(TaxRecord, on_delete=models.PROTECT, related_name='charges')
    authority = models.CharField(max_length=32, choices=AUTHORITY)
    charge_code = models.CharField(max_length=64)
    charge_name = models.CharField(max_length=128)
    legal_basis = models.CharField(max_length=256, blank=True)
    payer_role = models.CharField(max_length=32, blank=True)
    calculation_rate = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    calculation_basis = models.DecimalField(max_digits=14, decimal_places=2, null=True, blank=True)
    amount = models.DecimalField(max_digits=14, decimal_places=2, null=True, blank=True)
    currency = models.CharField(max_length=5, default='TZS')
    assessment_status = models.CharField(max_length=16, choices=STATUS, default='unavailable')
    assessment_reference = models.CharField(max_length=128, blank=True)
    payment_status = models.CharField(max_length=16, choices=PAYMENT_STATUS, default='not_started')
    payment_reference = models.CharField(max_length=128, blank=True)
    assessed_at = models.DateTimeField(null=True, blank=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'government_charges'
        ordering = ['created_at']


class AuditLog(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    actor = models.ForeignKey(settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL)
    action = models.CharField(max_length=50)
    entity_type = models.CharField(max_length=50)
    entity_id = models.CharField(max_length=64)
    payload = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'audit_logs'
        ordering = ['-created_at']
