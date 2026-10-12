"""Provider loading and safe null providers for integrations awaiting approval."""
from datetime import datetime
from decimal import Decimal, InvalidOperation
from django.conf import settings
from django.utils.module_loading import import_string


class NullCommissionPriceProvider:
    def get_prices(self):
        return []


class NullAssayProvider:
    def measure(self, *, transaction):
        return None


class NullChargeAssessmentProvider:
    def assess(self, *, transaction, assay):
        return None


class NullGovernmentPaymentProvider:
    def initiate(self, *, assessment, idempotency_key):
        return None


def validate_commission_prices(records):
    """Accept only provider-normalized, attributed, signature-verified records."""
    if not isinstance(records, list):
        return None
    required = {'price_type', 'value', 'currency', 'unit', 'effective_at', 'source', 'reference', 'verified', 'is_stale'}
    for record in records:
        if not isinstance(record, dict) or not required.issubset(record):
            return None
        try:
            value = Decimal(str(record['value']))
            if not value.is_finite() or value <= 0:
                return None
        except (InvalidOperation, TypeError, ValueError):
            return None
        if not all(record.get(key) for key in ('price_type', 'currency', 'unit', 'effective_at', 'source', 'reference')):
            return None
        try:
            effective_at = datetime.fromisoformat(str(record['effective_at']).replace('Z', '+00:00'))
            if effective_at.utcoffset() is None:
                return None
        except ValueError:
            return None
        if record.get('verified') is not True:
            return None
        if not isinstance(record.get('is_stale'), bool):
            return None
    return records


def get_provider(setting_name, null_provider):
    """Resolve a configured provider class, else return the disabled null adapter."""
    provider_path = getattr(settings, setting_name, '')
    if not provider_path:
        return null_provider()
    provider_class = import_string(provider_path)
    return provider_class()
