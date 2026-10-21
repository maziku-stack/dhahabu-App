from decimal import Decimal

from django.test import TestCase
from rest_framework.test import APIClient

from listings.models import Listing
from transactions.models import Transaction
from .models import DealerProfile, PrivacyRequest, User


class PrivacyFeatureTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            phone='0700000201', email='miner@example.test', password='Strong-pass-123',
            full_name='Private Miner', role='miner', region='Mwanza', mining_site='Site A',
        )
        self.other = User.objects.create_user(
            phone='0700000202', email='dealer@example.test', full_name='Buyer', role='dealer',
        )

    def test_export_returns_only_requesting_users_data_and_no_counterparty_phone(self):
        listing = Listing.objects.create(
            miner=self.user, weight_grams=Decimal('3.000'), karat='24K',
            asking_price=Decimal('300000.00'),
        )
        Transaction.objects.create(
            miner=self.user, dealer=self.other, listing=listing,
            weight_grams=Decimal('3.000'), karat='24K',
            price_per_gram=Decimal('100000.00'), agreed_price=Decimal('300000.00'),
            created_by=self.user,
        )
        self.client.force_authenticate(self.user)

        response = self.client.get('/api/auth/privacy/export/')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Cache-Control'], 'no-store, private')
        self.assertEqual(response.data['profile']['phone'], self.user.phone)
        self.assertEqual(len(response.data['listings']), 1)
        self.assertEqual(response.data['transactions'][0]['counterparty_name'], 'Buyer')
        self.assertNotIn('counterparty_phone', response.data['transactions'][0])
        self.assertNotIn(self.other.phone, str(response.data))

    def test_privacy_requests_are_private_and_recorded_for_review(self):
        self.client.force_authenticate(self.user)
        response = self.client.post('/api/auth/privacy/requests/', {
            'request_type': 'deletion', 'details': 'Please review my deletion request.'
        }, format='json')

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data['status'], 'received')
        self.assertEqual(PrivacyRequest.objects.get().user, self.user)

        self.client.force_authenticate(self.other)
        response = self.client.get('/api/auth/privacy/requests/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data, [])

    def test_registration_requires_current_privacy_notice_version(self):
        payload = {
            'full_name': 'New Miner', 'email': 'new@example.test', 'phone': '0700000299',
            'role': 'miner', 'password': 'Strong-password-123',
            'password_confirmation': 'Strong-password-123',
            'privacy_notice_acknowledged': True,
        }
        response = self.client.post('/api/auth/register/', payload, format='json')
        self.assertEqual(response.status_code, 400)
        payload['privacy_notice_version'] = '2026-10-draft-1'
        response = self.client.post('/api/auth/register/', payload, format='json')
        self.assertEqual(response.status_code, 201)
        created = User.objects.get(phone='0700000299')
        self.assertEqual(created.privacy_notice_version, '2026-10-draft-1')
        self.assertIsNotNone(created.privacy_acknowledged_at)


class EmailPasswordAuthFlowTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.registration = {
            'full_name': 'QA Miner',
            'email': 'qa.miner@example.test',
            'phone': '0700000501',
            'role': 'miner',
            'password': 'Mine-Gold-Strong-55!',
            'password_confirmation': 'Mine-Gold-Strong-55!',
            'privacy_notice_version': '2026-10-draft-1',
            'privacy_notice_acknowledged': True,
        }

    def test_register_login_and_authenticated_profile_round_trip(self):
        registered = self.client.post(
            '/api/auth/register/', self.registration, format='json'
        )
        self.assertEqual(registered.status_code, 201, registered.data)
        self.assertEqual(registered.data['user']['email'], self.registration['email'])
        self.assertTrue(registered.data['access'])
        self.assertTrue(registered.data['refresh'])

        logged_in = self.client.post('/api/auth/login/', {
            'email': self.registration['email'].upper(),
            'password': self.registration['password'],
        }, format='json')
        self.assertEqual(logged_in.status_code, 200, logged_in.data)
        self.assertEqual(logged_in.data['user']['id'], registered.data['user']['id'])

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {logged_in.data['access']}")
        profile = self.client.get('/api/auth/me/')
        self.assertEqual(profile.status_code, 200, profile.data)
        self.assertEqual(profile.data['phone'], self.registration['phone'])
        self.assertEqual(profile.data['role'], 'miner')

    def test_registration_creates_pending_dealer_profile(self):
        payload = {
            **self.registration,
            'email': 'qa.dealer@example.test',
            'phone': '0700000502',
            'role': 'dealer',
        }
        response = self.client.post('/api/auth/register/', payload, format='json')
        self.assertEqual(response.status_code, 201, response.data)
        profile = DealerProfile.objects.get(user__phone=payload['phone'])
        self.assertEqual(profile.verification_status, 'pending')

    def test_duplicate_email_or_phone_returns_validation_error(self):
        first = self.client.post('/api/auth/register/', self.registration, format='json')
        self.assertEqual(first.status_code, 201)

        duplicate_email = {
            **self.registration,
            'phone': '0700000503',
        }
        email_response = self.client.post(
            '/api/auth/register/', duplicate_email, format='json'
        )
        self.assertEqual(email_response.status_code, 400)

        duplicate_phone = {
            **self.registration,
            'email': 'another@example.test',
        }
        phone_response = self.client.post(
            '/api/auth/register/', duplicate_phone, format='json'
        )
        self.assertEqual(phone_response.status_code, 400)

    def test_login_rejects_wrong_password(self):
        registered = self.client.post(
            '/api/auth/register/', self.registration, format='json'
        )
        self.assertEqual(registered.status_code, 201)

        response = self.client.post('/api/auth/login/', {
            'email': self.registration['email'],
            'password': 'wrong password',
        }, format='json')
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data['detail'], 'Invalid email or password.')
