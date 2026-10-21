from datetime import datetime, timezone as datetime_timezone
from decimal import Decimal
from unittest.mock import patch

from django.test import SimpleTestCase, TestCase
from django.utils import timezone
from rest_framework.test import APIClient

from accounts.models import User
from integrations.providers import IndicativeMarketPriceProvider, validate_commission_prices
from pricing.models import ReferencePriceSnapshot


class CommissionPriceValidationTests(SimpleTestCase):
    def test_accepts_only_attributed_verified_records(self):
        record = {
            'price_type': 'buying_centre_price',
            'value': '123456.78',
            'currency': 'TZS',
            'unit': 'gram',
            'effective_at': '2026-10-12T10:00:00+03:00',
            'source': 'Mining Commission',
            'reference': 'PUB-123',
            'verified': True,
            'is_stale': False,
        }
        self.assertEqual(validate_commission_prices([record]), [record])

    def test_rejects_unsigned_and_malformed_records(self):
        record = {
            'price_type': 'buying_centre_price',
            'value': '123456.78',
            'currency': 'TZS',
            'unit': 'gram',
            'effective_at': '2026-10-12T10:00:00+03:00',
            'source': 'Mining Commission',
            'reference': 'PUB-123',
            'verified': False,
            'is_stale': False,
        }
        self.assertIsNone(validate_commission_prices([record]))
        self.assertIsNone(validate_commission_prices([{'value': 10}]))
        self.assertIsNone(validate_commission_prices('not a feed'))

    def test_rejects_nonfinite_amounts_and_timezone_free_timestamps(self):
        record = {
            'price_type': 'buying_centre_price',
            'value': 'NaN',
            'currency': 'TZS',
            'unit': 'gram',
            'effective_at': '2026-10-12T10:00:00+03:00',
            'source': 'Mining Commission',
            'reference': 'PUB-123',
            'verified': True,
            'is_stale': False,
        }
        self.assertIsNone(validate_commission_prices([record]))
        record['value'] = '123456.78'
        record['effective_at'] = '2026-10-12T10:00:00'
        self.assertIsNone(validate_commission_prices([record]))


class IndicativeMarketPriceProviderTests(SimpleTestCase):
    @patch.object(IndicativeMarketPriceProvider, '_get_json')
    def test_normalizes_gold_and_fx_to_estimated_tzs_per_gram(self, get_json):
        get_json.side_effect = [
            {'symbol': 'XAU', 'currency': 'USD', 'price': '3000', 'updatedAt': timezone.now().isoformat()},
            {'base': 'USD', 'quote': 'TZS', 'rate': '2600', 'date': timezone.localdate().isoformat()},
        ]

        result = IndicativeMarketPriceProvider().get_snapshot()

        self.assertEqual(result['gold_usd_per_troy_ounce'], Decimal('3000'))
        self.assertEqual(result['usd_to_tzs'], Decimal('2600'))
        self.assertEqual(
            result['tzs_per_gram'].quantize(Decimal('0.000001')),
            Decimal('250775.823235'),
        )
        self.assertEqual(result['gold_effective_at'].utcoffset(), datetime_timezone.utc.utcoffset(None))
        self.assertEqual(get_json.call_count, 2)

    @patch.object(IndicativeMarketPriceProvider, '_get_json')
    def test_rejects_invalid_provider_values(self, get_json):
        get_json.side_effect = [
            {'symbol': 'XAU', 'currency': 'USD', 'price': 'NaN', 'updatedAt': timezone.now().isoformat()},
            {'base': 'USD', 'quote': 'TZS', 'rate': '2600', 'date': timezone.localdate().isoformat()},
        ]
        with self.assertRaises(ValueError):
            IndicativeMarketPriceProvider().get_snapshot()


class IndicativeReferencePriceEndpointTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(phone='0700000401', role='miner')
        self.client = APIClient()

    def test_endpoint_requires_authentication(self):
        response = self.client.get('/api/pricing/reference/')
        self.assertEqual(response.status_code, 401)

    def test_endpoint_reports_unavailable_until_first_refresh(self):
        self.client.force_authenticate(self.user)
        response = self.client.get('/api/pricing/reference/')
        self.assertEqual(response.status_code, 503)
        self.assertFalse(response.data['official'])
        self.assertEqual(response.data['status'], 'not_available')

    def test_endpoint_returns_provisional_price_and_marks_stale_data(self):
        ReferencePriceSnapshot.objects.create(
            gold_usd_per_troy_ounce=Decimal('3000.000000'),
            usd_to_tzs=Decimal('2600.00000000'),
            tzs_per_gram=Decimal('250775.823235'),
            gold_effective_at=datetime(2026, 10, 20, tzinfo=datetime_timezone.utc),
            fx_effective_date=timezone.localdate(),
            gold_source='Gold-API.com', fx_source='Frankfurter',
            fetched_at=timezone.now(),
        )
        self.client.force_authenticate(self.user)

        response = self.client.get('/api/pricing/reference/')

        self.assertEqual(response.status_code, 200)
        self.assertFalse(response.data['official'])
        self.assertEqual(response.data['status'], 'stale')
        self.assertEqual(response.data['price']['currency'], 'TZS')
        self.assertEqual(response.data['price']['unit'], 'gram')
        self.assertEqual(response.data['sources'], ['Gold-API.com', 'Frankfurter'])
