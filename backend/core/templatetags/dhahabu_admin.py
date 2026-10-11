from datetime import datetime

from django import template
from django.db.models import Sum
from django.utils import timezone

from accounts.models import DealerProfile, User
from feedback.models import Feedback
from listings.models import Listing
from pricing.models import GoldPrice
from transactions.models import Transaction

register = template.Library()


def _month_start(year, month):
    return datetime(year, month, 1, tzinfo=timezone.get_current_timezone())


def _month_after(year, month):
    return _month_start(year + (month == 12), 1 if month == 12 else month + 1)


@register.simple_tag(takes_context=True)
def dashboard_summary(context):
    request = context['request']
    user = request.user

    def can_view(app, model):
        return user.is_superuser or user.has_perm(f'{app}.view_{model}')

    has_users = can_view('accounts', 'user')
    has_dealers = can_view('accounts', 'dealerprofile')
    has_listings = can_view('listings', 'listing')
    has_transactions = can_view('transactions', 'transaction')
    has_feedback = can_view('feedback', 'feedback')
    has_prices = can_view('pricing', 'goldprice')

    confirmed = Transaction.objects.filter(status='confirmed') if has_transactions else Transaction.objects.none()
    month = timezone.localtime().date().replace(day=1)
    months = []
    for offset in reversed(range(6)):
        month_number = month.month - offset
        year = month.year
        while month_number <= 0:
            month_number += 12
            year -= 1
        start = _month_start(year, month_number)
        end = _month_after(year, month_number)
        amount = confirmed.filter(confirmed_at__gte=start, confirmed_at__lt=end).aggregate(
            total=Sum('agreed_price')
        )['total'] or 0
        months.append({'label': start.strftime('%b'), 'amount': amount})

    peak = max((float(item['amount']) for item in months), default=0) or 1
    for item in months:
        item['height'] = max(5, round(float(item['amount']) / peak * 100))

    pending_dealers = DealerProfile.objects.filter(
        verification_status='pending'
    ) if has_dealers else DealerProfile.objects.none()
    open_feedback = Feedback.objects.filter(
        status__in=['open', 'reviewing']
    ) if has_feedback else Feedback.objects.none()

    return {
        'miner_count': User.objects.filter(role='miner').count() if has_users else None,
        'dealer_count': User.objects.filter(role='dealer').count() if has_users else None,
        'pending_dealers': pending_dealers.count(),
        'open_listings': Listing.objects.filter(status='open').count() if has_listings else None,
        'pending_transactions': Transaction.objects.filter(status='pending_confirm').count() if has_transactions else None,
        'confirmed_volume': confirmed.aggregate(total=Sum('agreed_price'))['total'] or 0,
        'open_feedback': open_feedback.count(),
        'active_prices': GoldPrice.objects.filter(is_active=True).count() if has_prices else None,
        'recent_transactions': Transaction.objects.select_related('miner', 'dealer').order_by('-created_at')[:6] if has_transactions else [],
        'recent_feedback': open_feedback.select_related('submitter').order_by('-created_at')[:4],
        'months': months,
        'can_view_users': has_users,
        'can_view_dealers': has_dealers,
        'can_view_listings': has_listings,
        'can_view_transactions': has_transactions,
        'can_view_feedback': has_feedback,
        'can_view_prices': has_prices,
        'can_view_audit': can_view('transactions', 'auditlog'),
        'can_view_tax': can_view('transactions', 'taxrecord'),
    }
