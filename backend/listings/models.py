import uuid
from django.db import models
from django.conf import settings

class Listing(models.Model):
    STATUS = [('open', 'Open'), ('sold', 'Sold'), ('cancelled', 'Cancelled')]
    KARAT = [('24K', '24K'), ('22K', '22K'), ('18K', '18K')]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    miner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='listings')
    weight_grams = models.DecimalField(max_digits=10, decimal_places=3)
    karat = models.CharField(max_length=5, choices=KARAT)
    asking_price = models.DecimalField(max_digits=14, decimal_places=2)
    price_per_gram = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    notes = models.TextField(blank=True)
    region = models.CharField(max_length=100, blank=True)
    status = models.CharField(max_length=20, choices=STATUS, default='open')
    photo = models.ImageField(upload_to='listings/%Y/%m/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'listings'
        ordering = ['-created_at']
