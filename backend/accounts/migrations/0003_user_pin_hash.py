from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0002_otpcode_locked_until_user_pin_set_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='pin_hash',
            field=models.CharField(blank=True, default='', max_length=128),
        ),
    ]
