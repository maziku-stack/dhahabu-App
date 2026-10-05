from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

User = get_user_model()

class Command(BaseCommand):
    help = 'Create Government Admin user'

    def add_arguments(self, parser):
        parser.add_argument('--phone', default='0700000001')
        parser.add_argument('--name', default='Government Admin')

    def handle(self, *args, **options):
        phone = options['phone'].strip()
        user, created = User.objects.get_or_create(
            phone=phone,
            defaults={
                'full_name': options['name'],
                'role': 'admin',
                'phone_verified': True,
                'is_staff': True,
                'pin_set': True,
            },
        )
        if not created:
            user.role = 'admin'
            user.phone_verified = True
            user.is_staff = True
            user.save()
        self.stdout.write(self.style.SUCCESS(f'Admin ready: {phone} (OTP 123456 when MOCK_OTP=True)'))
