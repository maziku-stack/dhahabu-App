from django.contrib import admin
from .models import Transaction, TaxRecord, AuditLog, GovernmentCharge

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('id', 'miner', 'dealer', 'weight_grams', 'karat', 'agreed_price', 'status')
    list_filter = ('status', 'karat')
    readonly_fields = [field.name for field in Transaction._meta.fields]

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj=None):
        return False

@admin.register(TaxRecord)
class TaxRecordAdmin(admin.ModelAdmin):
    list_display = ('id', 'transaction', 'royalty_amount', 'royalty_rate', 'created_at')
    readonly_fields = [field.name for field in TaxRecord._meta.fields]

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj=None):
        return False

@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ('action', 'entity_type', 'entity_id', 'actor', 'created_at')
    readonly_fields = [field.name for field in AuditLog._meta.fields]

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj=None):
        return False

@admin.register(GovernmentCharge)
class GovernmentChargeAdmin(admin.ModelAdmin):
    list_display = ('charge_name', 'authority', 'amount', 'currency', 'assessment_status', 'payment_status')
    list_filter = ('authority', 'assessment_status', 'payment_status')
    readonly_fields = [field.name for field in GovernmentCharge._meta.fields]

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
