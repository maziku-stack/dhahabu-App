"""Provider loading and safe null providers for integrations awaiting approval."""
import json
from datetime import datetime, timedelta
from decimal import Decimal, InvalidOperation
from urllib.error import URLError
from urllib.request import Request, urlopen

from django.conf import settings
from django.utils.module_loading import import_string
from django.utils import timezone


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


class IndicativeMarketPriceProvider:
    """Fetch third-party gold spot and FX data for indicative display only."""

    TROY_OUNCE_GRAMS = Decimal('31.1034768')

    def __init__(self, *, timeout=5):
        self.timeout = timeout
        self.gold_url = getattr(
            settings, 'DH_REFERENCE_GOLD_PRICE_URL',
            'https://api.gold-api.com/price/XAU',
        )
        self.fx_url = getattr(
            settings, 'DH_REFERENCE_FX_URL',
            'https://api.frankfurter.dev/v2/rate/USD/TZS',
        )

    def _get_json(self, url):
        request = Request(url, headers={'Accept': 'application/json', 'User-Agent': 'Dhahabu/1.0'})
        try:
            with urlopen(request, timeout=self.timeout) as response:
                if response.status != 200:
                    raise ValueError('Provider returned a non-success response.')
                return json.loads(response.read().decode('utf-8'))
        except (URLError, TimeoutError) as exc:
            raise ValueError('Reference price provider is unavailable.') from exc
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise ValueError('Reference price provider returned invalid JSON.') from exc

    def get_snapshot(self):
        gold = self._get_json(self.gold_url)
        fx = self._get_json(self.fx_url)

        if (not isinstance(gold, dict) or gold.get('symbol') != 'XAU'
                or gold.get('currency') != 'USD'):
            raise ValueError('Gold provider response did not identify XAU.')
        if not isinstance(fx, dict) or fx.get('base') != 'USD' or fx.get('quote') != 'TZS':
            raise ValueError('FX provider response did not identify USD/TZS.')

        try:
            gold_usd_per_troy_ounce = Decimal(str(gold['price']))
            usd_to_tzs = Decimal(str(fx['rate']))
            gold_effective_at = datetime.fromisoformat(
                str(gold['updatedAt']).replace('Z', '+00:00')
            )
            fx_effective_date = datetime.fromisoformat(str(fx['date'])).date()
        except (KeyError, TypeError, ValueError, InvalidOperation) as exc:
            raise ValueError('Reference price provider response was malformed.') from exc

        if (not gold_usd_per_troy_ounce.is_finite() or gold_usd_per_troy_ounce <= 0
                or not usd_to_tzs.is_finite() or usd_to_tzs <= 0
                or gold_effective_at.utcoffset() is None
                or gold_effective_at > timezone.now() + timedelta(minutes=5)
                or fx_effective_date > timezone.localdate()):
            raise ValueError('Reference price provider values were invalid.')

        return {
            'gold_usd_per_troy_ounce': gold_usd_per_troy_ounce,
            'usd_to_tzs': usd_to_tzs,
            'tzs_per_gram': (gold_usd_per_troy_ounce * usd_to_tzs / self.TROY_OUNCE_GRAMS),
            'gold_effective_at': gold_effective_at,
            'fx_effective_date': fx_effective_date,
            'gold_source': 'Gold-API.com',
            'fx_source': 'Frankfurter',
            'fetched_at': timezone.now(),
        }


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
