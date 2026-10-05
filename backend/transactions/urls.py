from django.urls import path
from .views import (
    CreateTransactionView, ConfirmTransactionView, MyTransactionsView,
    TransactionDetailView, TaxSummaryView, AdminDashboardView, AuditLogListView,
)
urlpatterns = [
    path('', MyTransactionsView.as_view()),
    path('create/', CreateTransactionView.as_view()),
    path('tax-summary/', TaxSummaryView.as_view()),
    path('admin/dashboard/', AdminDashboardView.as_view()),
    path('admin/audit/', AuditLogListView.as_view()),
    path('<uuid:txn_id>/', TransactionDetailView.as_view()),
    path('<uuid:txn_id>/confirm/', ConfirmTransactionView.as_view()),
]
