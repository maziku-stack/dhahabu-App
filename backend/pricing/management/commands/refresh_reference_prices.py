from datetime import timedelta

from django.core.management.base import BaseCommand, CommandError
from django.utils import timezone

from integrations.providers import IndicativeMarketPriceProvider
from pricing.models import ReferencePriceSnapshot


class Command(BaseCommand):
    help = 'Fetch and store the latest indicative gold reference price.'

    def handle(self, *args, **options):
        try:
            snapshot = IndicativeMarketPriceProvider().get_snapshot()
            saved = ReferencePriceSnapshot.objects.create(**snapshot)
        except Exception as exc:
            raise CommandError(f'Could not refresh reference price: {exc}') from exc

        ReferencePriceSnapshot.objects.filter(
            fetched_at__lt=timezone.now() - timedelta(days=30)
        ).delete()

        self.stdout.write(self.style.SUCCESS(
            f'Saved indicative reference snapshot {saved.pk} '
            f'({saved.gold_usd_per_troy_ounce} USD/troy oz; '
            f'{saved.tzs_per_gram} TZS/g).'
        ))
