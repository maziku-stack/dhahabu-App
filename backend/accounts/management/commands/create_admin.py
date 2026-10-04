"""
Create a Government Admin user for Dhahabu.

Usage:
  python manage.py create_admin --phone 0700000001 --name "TRA Admin"
"""
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

User = get_user_model()


class Command(BaseCommand):
    help = 'Create a Government Admin user (phone-based)'

    def add_arguments(self, parser):
        parser.add_argument('--phone', type=str, default='0700000001')
        parser.add_argument('--name', type=str, default='Government Admin')
        parser.add_argument('--region', type=str, default='National')

    def handle(self, *args, **options):
        phone = options['phone'].strip()
        name = options['name']
        region = options['region']

        user, created = User.objects.get_or_create(
            phone=phone,
            defaults={
                'full_name': name,
                'role': 'admin',
                'phone_verified': True,
                'is_staff': True,
                'region': region,
            },
        )
        if not created:
            user.role = 'admin'
            user.phone_verified = True
            user.is_staff = True
            user.full_name = name
            user.save()
            self.stdout.write(self.style.WARNING(f'Admin already existed — updated: {phone}'))
        else:
            self.stdout.write(self.style.SUCCESS(f'Admin created: {phone} ({name})'))

        self.stdout.write('')
        self.stdout.write('Login in the app:')
        self.stdout.write(f'  1. Select role: Gov (Admin)')
        self.stdout.write(f'  2. Phone: {phone}')
        self.stdout.write(f'  3. OTP: 123456  (when MOCK_OTP=True)')
