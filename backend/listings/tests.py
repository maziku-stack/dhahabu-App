from decimal import Decimal

from django.test import TestCase
from rest_framework.test import APIClient

from accounts.models import User
from .models import Listing


class ListingPhonePrivacyTests(TestCase):
    def setUp(self):
        self.miner = User.objects.create_user(phone='0700000301', role='miner', full_name='Miner')
        self.dealer = User.objects.create_user(phone='0700000302', role='dealer')
        self.listing = Listing.objects.create(
            miner=self.miner, weight_grams=Decimal('1.000'), karat='24K',
            asking_price=Decimal('100000.00'),
        )
        self.client = APIClient()
        self.client.force_authenticate(self.dealer)

    def test_phone_hidden_by_default(self):
        response = self.client.get('/api/listings/?browse=1')
        self.assertEqual(response.status_code, 200)
        item = response.data.get('results', [])[0] if isinstance(response.data, dict) else response.data[0]
        self.assertIsNone(item['miner_phone'])
        self.assertNotIn('miner', item)

    def test_phone_visible_only_after_listing_opt_in(self):
        self.listing.share_phone = True
        self.listing.save(update_fields=['share_phone'])
        response = self.client.get('/api/listings/?browse=1')
        item = response.data.get('results', [])[0] if isinstance(response.data, dict) else response.data[0]
        self.assertEqual(item['miner_phone'], self.miner.phone)

    def test_seller_can_revoke_phone_sharing_and_other_users_cannot_change_it(self):
        self.listing.share_phone = True
        self.listing.save(update_fields=['share_phone'])
        response = self.client.patch(
            f'/api/listings/{self.listing.pk}/', {'share_phone': False}, format='json'
        )
        self.assertEqual(response.status_code, 403)

        self.client.force_authenticate(self.miner)
        response = self.client.patch(
            f'/api/listings/{self.listing.pk}/', {'share_phone': False}, format='json'
        )
        self.assertEqual(response.status_code, 200)
        self.assertFalse(response.data['share_phone'])
