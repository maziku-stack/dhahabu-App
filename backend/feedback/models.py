import uuid
from django.db import models
from django.conf import settings


class Feedback(models.Model):
    TYPE_CHOICES = [
        ('feedback', 'General Feedback'),
        ('grievance', 'Grievance / Complaint'),
    ]
    STATUS_CHOICES = [
        ('open', 'Open'),
        ('reviewing', 'Under Review'),
        ('resolved', 'Resolved'),
        ('closed', 'Closed'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    submitter = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='feedbacks',
    )
    type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='feedback')
    subject = models.CharField(max_length=200)
    body = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='open')
    admin_response = models.TextField(blank=True)
    region = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'feedbacks'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.type}: {self.subject[:40]}'
