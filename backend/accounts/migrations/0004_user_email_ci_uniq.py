from django.db import migrations, models
from django.db.models import Q
from django.db.models.functions import Lower


class Migration(migrations.Migration):
    dependencies = [
        ('accounts', '0003_user_pin_hash'),
    ]

    operations = [
        migrations.AddConstraint(
            model_name='user',
            constraint=models.UniqueConstraint(
                Lower('email'),
                condition=Q(email__gt=''),
                name='users_email_ci_uniq',
            ),
        ),
    ]
