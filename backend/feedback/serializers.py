from rest_framework import serializers
from .models import Feedback

class FeedbackSerializer(serializers.ModelSerializer):
    submitter_name = serializers.CharField(source='submitter.full_name', read_only=True)
    submitter_phone = serializers.CharField(source='submitter.phone', read_only=True)

    class Meta:
        model = Feedback
        fields = ('id', 'type', 'subject', 'body', 'status', 'admin_response', 'region',
                  'submitter_name', 'submitter_phone', 'created_at', 'updated_at')
        read_only_fields = ('id', 'status', 'admin_response', 'created_at', 'updated_at',
                            'submitter_name', 'submitter_phone')

class FeedbackCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Feedback
        fields = ('type', 'subject', 'body', 'region')
