import uuid
from django.db import models
from django.conf import settings

class GoldPrice(models.Model):
    KARAT = [('24K', '24K'), ('22K', '22K'), ('18K', '18K')]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    karat = models.CharField(max_length=5, choices=KARAT)
    price_per_gram = models.DecimalField(max_digits=12, decimal_places=2)
    currency = models.CharField(max_length=5, default='TZS')
    source = models.CharField(max_length=100, blank=True, default='Manual')
    effective_at = models.DateTimeField()
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL)
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'gold_prices'
        ordering = ['-effective_at']


class ReferencePriceSnapshot(models.Model):
    """Third-party estimate, kept separate from official Commission prices."""
    gold_usd_per_troy_ounce = models.DecimalField(max_digits=16, decimal_places=6)
    usd_to_tzs = models.DecimalField(max_digits=16, decimal_places=8)
    tzs_per_gram = models.DecimalField(max_digits=18, decimal_places=6)
    gold_effective_at = models.DateTimeField()
    fx_effective_date = models.DateField()
    gold_source = models.CharField(max_length=100)
    fx_source = models.CharField(max_length=100)
    fetched_at = models.DateTimeField()

    class Meta:
        ordering = ['-fetched_at']
