from decimal import Decimal

from django.contrib.auth.hashers import make_password
from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient

from accounts.models import DealerProfile, User
from listings.models import Listing
from .models import AuditLog, TaxRecord, Transaction


class TransactionConfirmationTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.miner = User.objects.create_user(
            phone='0700000101', role='miner', full_name='Test Miner',
            pin_hash=make_password('2468'), pin_set=True,
        )
        self.dealer = User.objects.create_user(
            phone='0700000102', role='dealer', full_name='Test Dealer',
            pin_hash=make_password('1357'), pin_set=True,
        )
        DealerProfile.objects.create(
            user=self.dealer, business_name='Test Gold',
            verification_status='verified',
        )
        self.other_miner = User.objects.create_user(
            phone='0700000103', role='miner',
        )
        self.listing = Listing.objects.create(
            miner=self.miner, weight_grams=Decimal('10.000'), karat='24K',
            asking_price=Decimal('1000000.00'),
        )
        self.transaction = Transaction.objects.create(
            miner=self.miner, dealer=self.dealer, listing=self.listing,
            weight_grams=Decimal('10.000'), karat='24K',
            price_per_gram=Decimal('100000.00'), agreed_price=Decimal('1000000.00'),
            created_by=self.dealer, dealer_confirmed_at=timezone.now(),
        )
        self.url = f'/api/transactions/{self.transaction.id}/confirm/'

    def test_miner_confirmation_creates_unassessed_charge_record_and_sells_listing(self):
        self.client.force_authenticate(self.miner)

        response = self.client.post(self.url, {'pin': '2468'}, format='json')

        self.assertEqual(response.status_code, 200)
        self.transaction.refresh_from_db()
        self.listing.refresh_from_db()
        self.assertEqual(self.transaction.status, 'confirmed')
        self.assertIsNotNone(self.transaction.confirmed_at)
        self.assertEqual(self.listing.status, 'sold')
        self.assertEqual(TaxRecord.objects.filter(transaction=self.transaction).count(), 1)
        tax = TaxRecord.objects.get(transaction=self.transaction)
        self.assertIsNone(tax.tax_base)
        self.assertIsNone(tax.royalty_amount)
        self.assertIsNone(tax.royalty_rate)
        self.assertEqual(tax.assessment_status, 'unavailable')
        self.assertEqual(tax.payment_status, 'not_started')
        self.assertEqual(AuditLog.objects.filter(action='transaction.confirmed').count(), 1)

    def test_wrong_pin_does_not_confirm_or_create_tax(self):
        self.client.force_authenticate(self.miner)

        response = self.client.post(self.url, {'pin': '0000'}, format='json')

        self.assertEqual(response.status_code, 400)
        self.transaction.refresh_from_db()
        self.assertEqual(self.transaction.status, 'pending_confirm')
        self.assertFalse(TaxRecord.objects.filter(transaction=self.transaction).exists())
        self.assertEqual(self.listing.status, 'open')

    def test_non_miner_cannot_confirm_another_users_sale(self):
        self.client.force_authenticate(self.other_miner)

        response = self.client.post(self.url, {'pin': '2468'}, format='json')

        self.assertEqual(response.status_code, 403)
        self.transaction.refresh_from_db()
        self.assertEqual(self.transaction.status, 'pending_confirm')
        self.assertFalse(TaxRecord.objects.filter(transaction=self.transaction).exists())

    def test_repeated_confirmation_does_not_duplicate_royalty(self):
        self.client.force_authenticate(self.miner)
        first = self.client.post(self.url, {'pin': '2468'}, format='json')
        second = self.client.post(self.url, {'pin': '2468'}, format='json')

        self.assertEqual(first.status_code, 200)
        self.assertEqual(second.status_code, 200)
        self.assertEqual(TaxRecord.objects.filter(transaction=self.transaction).count(), 1)
        self.assertEqual(AuditLog.objects.filter(action='transaction.confirmed').count(), 1)

    def test_price_endpoint_never_returns_manual_prices_as_official(self):
        from pricing.models import GoldPrice
        from django.utils import timezone
        GoldPrice.objects.create(
            karat='24K', price_per_gram=Decimal('999999.00'),
            effective_at=timezone.now(), created_by=self.miner,
        )
        self.client.force_authenticate(self.miner)

        response = self.client.get('/api/pricing/current/')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['status'], 'not_configured')
        self.assertFalse(response.data['official'])
        self.assertEqual(response.data['prices'], [])

    def test_admin_cannot_publish_manual_price_as_official(self):
        admin = User.objects.create_user(phone='0700000105', role='admin')
        self.client.force_authenticate(admin)

        response = self.client.post('/api/pricing/set/', {
            'karat': '24K', 'price_per_gram': '100000.00',
        }, format='json')

        self.assertEqual(response.status_code, 503)
        from pricing.models import GoldPrice
        self.assertFalse(GoldPrice.objects.exists())

    def test_each_party_must_confirm_before_sale_is_finalized(self):
        self.transaction.dealer_confirmed_at = None
        self.transaction.save(update_fields=['dealer_confirmed_at'])
        self.client.force_authenticate(self.miner)

        miner_response = self.client.post(self.url, {'pin': '2468'}, format='json')

        self.assertEqual(miner_response.status_code, 200)
        self.assertEqual(miner_response.data['status'], 'pending_confirm')
        self.assertFalse(TaxRecord.objects.filter(transaction=self.transaction).exists())
        self.assertIsNotNone(miner_response.data['miner_confirmed_at'])
        self.assertIsNone(miner_response.data['dealer_confirmed_at'])

        self.client.force_authenticate(self.dealer)
        dealer_response = self.client.post(self.url, {'pin': '1357'}, format='json')

        self.assertEqual(dealer_response.status_code, 200)
        self.assertEqual(dealer_response.data['status'], 'confirmed')
        self.assertEqual(TaxRecord.objects.filter(transaction=self.transaction).count(), 1)

    def test_admin_cannot_confirm_for_either_party(self):
        admin = User.objects.create_user(phone='0700000104', role='admin')
        self.client.force_authenticate(admin)

        response = self.client.post(self.url, {'pin': '2468'}, format='json')

        self.assertEqual(response.status_code, 403)
        self.assertFalse(TaxRecord.objects.filter(transaction=self.transaction).exists())

    def test_legacy_default_estimate_is_preserved_but_not_exposed_as_official(self):
        tax = TaxRecord.objects.create(
            transaction=self.transaction,
            royalty_rate=Decimal('0.0700'),
            royalty_amount=Decimal('70000.00'),
            tax_base=Decimal('1000000.00'),
            assessment_status='unavailable',
        )
        self.client.force_authenticate(self.miner)

        response = self.client.get(f'/api/transactions/{self.transaction.id}/')

        self.assertEqual(response.status_code, 200)
        self.assertIsNone(response.data['tax_record']['royalty_rate'])
        self.assertIsNone(response.data['tax_record']['royalty_amount'])
        self.assertEqual(TaxRecord.objects.get(id=tax.id).royalty_amount, Decimal('70000.00'))


class TransactionCreationTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.miner = User.objects.create_user(phone='0700000201', role='miner')
        self.other_miner = User.objects.create_user(phone='0700000202', role='miner')
        self.dealer = User.objects.create_user(phone='0700000203', role='dealer')
        self.profile = DealerProfile.objects.create(
            user=self.dealer, business_name='Test Gold', verification_status='verified',
        )
        self.listing = Listing.objects.create(
            miner=self.miner, weight_grams=Decimal('10.000'), karat='24K',
            asking_price=Decimal('1000000.00'),
        )
        self.client.force_authenticate(self.miner)
        self.url = '/api/transactions/create/'
        self.payload = {
            'counterparty_phone': self.dealer.phone,
            'weight_grams': '10.000',
            'karat': '24K',
            'price_per_gram': '100000.00',
            'listing_id': str(self.listing.id),
        }

    def test_unverified_dealer_cannot_be_used_for_a_sale(self):
        self.profile.verification_status = 'pending'
        self.profile.save(update_fields=['verification_status'])

        response = self.client.post(self.url, self.payload, format='json')

        self.assertEqual(response.status_code, 403)
        self.assertFalse(Transaction.objects.exists())

    def test_sale_must_match_listing_weight_and_karat(self):
        payload = {**self.payload, 'weight_grams': '9.000'}

        response = self.client.post(self.url, payload, format='json')

        self.assertEqual(response.status_code, 400)
        self.assertFalse(Transaction.objects.exists())

    def test_listing_owner_must_match_sale_miner(self):
        payload = {**self.payload, 'counterparty_phone': self.dealer.phone}
        # Create as the dealer so the counterparty is a different miner.
        self.client.force_authenticate(self.dealer)
        payload['counterparty_phone'] = self.other_miner.phone

        response = self.client.post(self.url, payload, format='json')

        self.assertEqual(response.status_code, 400)
        self.assertFalse(Transaction.objects.exists())

    def test_retry_with_same_client_reference_returns_existing_transaction(self):
        payload = {**self.payload, 'client_ref': 'mobile-retry-001'}
        first = self.client.post(self.url, payload, format='json')
        retry = self.client.post(
            self.url,
            {**payload, 'weight_grams': '9.000', 'price_per_gram': '1.00'},
            format='json',
        )

        self.assertEqual(first.status_code, 201)
        self.assertEqual(retry.status_code, 200)
        self.assertEqual(retry.data['id'], first.data['id'])
        self.assertIsNone(first.data['miner_confirmed_at'])
        self.assertIsNone(first.data['dealer_confirmed_at'])
        self.assertEqual(Transaction.objects.count(), 1)

    def test_sale_creator_must_confirm_separately_with_pin(self):
        response = self.client.post(self.url, self.payload, format='json')
        txn = Transaction.objects.get(id=response.data['id'])
        self.assertEqual(response.status_code, 201)
        self.assertIsNone(txn.miner_confirmed_at)
        self.assertIsNone(txn.dealer_confirmed_at)
        self.assertFalse(TaxRecord.objects.filter(transaction=txn).exists())
