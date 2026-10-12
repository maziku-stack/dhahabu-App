from decimal import Decimal

from django.contrib.auth.hashers import make_password
from django.test import TestCase
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
            created_by=self.dealer,
        )
        self.url = f'/api/transactions/{self.transaction.id}/confirm/'

    def test_miner_confirmation_creates_royalty_and_sells_listing(self):
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
        self.assertEqual(tax.tax_base, Decimal('1000000.00'))
        self.assertEqual(tax.royalty_amount, Decimal('70000.00'))
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
        self.assertEqual(Transaction.objects.count(), 1)
