from django.test import SimpleTestCase

from integrations.providers import validate_commission_prices


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
