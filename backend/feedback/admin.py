from django.contrib import admin
from .models import Feedback

@admin.register(Feedback)
class FeedbackAdmin(admin.ModelAdmin):
    list_display = ('subject', 'type', 'submitter', 'status', 'region', 'created_at')
    list_filter = ('type', 'status')
    search_fields = ('subject', 'submitter__phone')
