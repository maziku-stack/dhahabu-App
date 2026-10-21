from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('pricing', '0002_remove_goldprice_gold_prices_karat_807a24_idx_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='ReferencePriceSnapshot',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('gold_usd_per_troy_ounce', models.DecimalField(decimal_places=6, max_digits=16)),
                ('usd_to_tzs', models.DecimalField(decimal_places=8, max_digits=16)),
                ('tzs_per_gram', models.DecimalField(decimal_places=6, max_digits=18)),
                ('gold_effective_at', models.DateTimeField()),
                ('fx_effective_date', models.DateField()),
                ('gold_source', models.CharField(max_length=100)),
                ('fx_source', models.CharField(max_length=100)),
                ('fetched_at', models.DateTimeField()),
            ],
            options={'ordering': ['-fetched_at']},
        ),
    ]
