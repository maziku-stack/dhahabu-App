import uuid
from django.db import models
from django.conf import settings


class GoldPrice(models.Model):
    """Daily market price per gram by karat purity."""
    KARAT_CHOICES = [
        ('24K', '24 Karat'),
        ('22K', '22 Karat'),
        ('18K', '18 Karat'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    karat = models.CharField(max_length=5, choices=KARAT_CHOICES)
    price_per_gram = models.DecimalField(max_digits=12, decimal_places=2)  # TZS
    currency = models.CharField(max_length=5, default='TZS')
    source = models.CharField(max_length=100, blank=True, default='Manual')
    effective_at = models.DateTimeField()
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='prices_set',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'gold_prices'
        ordering = ['-effective_at']
        indexes = [models.Index(fields=['karat', '-effective_at'])]

    def __str__(self):
        return f'{self.karat}: {self.price_per_gram} {self.currency}/g @ {self.effective_at}'
