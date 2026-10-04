from django.contrib import admin
from .models import Transaction, TaxRecord, AuditLog


class TaxRecordInline(admin.StackedInline):
    model = TaxRecord
    readonly_fields = ('royalty_rate', 'royalty_amount', 'tax_base', 'created_at')
    can_delete = False
    extra = 0


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('id', 'miner', 'dealer', 'weight_grams', 'karat', 'agreed_price', 'status', 'confirmed_at')
    list_filter = ('status', 'karat')
    search_fields = ('miner__phone', 'dealer__phone', 'id')
    inlines = [TaxRecordInline]
    readonly_fields = ('created_at', 'confirmed_at')


@admin.register(TaxRecord)
class TaxRecordAdmin(admin.ModelAdmin):
    list_display = ('id', 'transaction', 'royalty_amount', 'royalty_rate', 'created_at', 'is_reversal')
    readonly_fields = ('royalty_rate', 'royalty_amount', 'tax_base', 'created_at')


@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ('action', 'entity_type', 'entity_id', 'actor', 'created_at')
    list_filter = ('action', 'entity_type')
    readonly_fields = ('actor', 'action', 'entity_type', 'entity_id', 'payload', 'ip_address', 'created_at')
