from django.contrib import admin
from .models import Listing
@admin.register(Listing)
class ListingAdmin(admin.ModelAdmin):
    list_display = ('id', 'miner', 'weight_grams', 'karat', 'asking_price', 'status', 'created_at')
    list_filter = ('status', 'karat')
