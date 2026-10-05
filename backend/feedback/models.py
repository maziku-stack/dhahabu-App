import uuid
from django.db import models
from django.conf import settings

class Feedback(models.Model):
    TYPE = [('feedback', 'Feedback'), ('grievance', 'Grievance')]
    STATUS = [('open', 'Open'), ('reviewing', 'Reviewing'), ('resolved', 'Resolved'), ('closed', 'Closed')]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    submitter = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='feedbacks')
    type = models.CharField(max_length=20, choices=TYPE, default='feedback')
    subject = models.CharField(max_length=200)
    body = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS, default='open')
    admin_response = models.TextField(blank=True)
    region = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'feedbacks'
        ordering = ['-created_at']
