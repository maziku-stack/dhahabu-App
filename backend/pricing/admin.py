from django.contrib import admin
from .models import GoldPrice

@admin.register(GoldPrice)
class GoldPriceAdmin(admin.ModelAdmin):
    list_display = ('karat', 'price_per_gram', 'currency', 'effective_at', 'source', 'is_active')
    list_filter = ('karat', 'is_active')
