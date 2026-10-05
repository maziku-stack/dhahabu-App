from django.contrib import admin
from .models import Transaction, TaxRecord, AuditLog

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('id', 'miner', 'dealer', 'weight_grams', 'karat', 'agreed_price', 'status')
    list_filter = ('status', 'karat')

@admin.register(TaxRecord)
class TaxRecordAdmin(admin.ModelAdmin):
    list_display = ('id', 'transaction', 'royalty_amount', 'royalty_rate', 'created_at')

@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ('action', 'entity_type', 'entity_id', 'actor', 'created_at')
