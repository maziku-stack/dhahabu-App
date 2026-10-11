from django import template
from django.db.models import Sum

from accounts.models import DealerProfile, User
from feedback.models import Feedback
from listings.models import Listing
from pricing.models import GoldPrice
from transactions.models import Transaction

register = template.Library()


@register.simple_tag
def dashboard_summary():
    confirmed_transactions = Transaction.objects.filter(status='confirmed')
    return {
        'miner_count': User.objects.filter(role='miner').count(),
        'dealer_count': User.objects.filter(role='dealer').count(),
        'pending_dealers': DealerProfile.objects.filter(
            verification_status='pending'
        ).count(),
        'open_listings': Listing.objects.filter(status='open').count(),
        'pending_transactions': Transaction.objects.filter(
            status='pending_confirm'
        ).count(),
        'confirmed_volume': confirmed_transactions.aggregate(
            total=Sum('agreed_price')
        )['total'] or 0,
        'open_feedback': Feedback.objects.filter(
            status__in=['open', 'reviewing']
        ).count(),
        'active_prices': GoldPrice.objects.filter(is_active=True).count(),
        'recent_transactions': Transaction.objects.select_related(
            'miner', 'dealer'
        ).order_by('-created_at')[:6],
    }
