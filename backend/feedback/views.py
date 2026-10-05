from rest_framework import generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Feedback
from .serializers import FeedbackSerializer, FeedbackCreateSerializer

class FeedbackListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        return FeedbackCreateSerializer if self.request.method == 'POST' else FeedbackSerializer

    def get_queryset(self):
        user = self.request.user
        if user.role == 'admin' or user.is_staff:
            return Feedback.objects.all().select_related('submitter')
        return Feedback.objects.filter(submitter=user)

    def perform_create(self, serializer):
        region = serializer.validated_data.get('region') or self.request.user.region
        serializer.save(submitter=self.request.user, region=region)

class FeedbackRespondView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        if request.user.role != 'admin' and not request.user.is_staff:
            return Response({'detail': 'Admin only.'}, status=403)
        try:
            fb = Feedback.objects.get(id=pk)
        except Feedback.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=404)
        fb.admin_response = request.data.get('response', '')
        fb.status = request.data.get('status', 'resolved')
        fb.save()
        return Response(FeedbackSerializer(fb).data)
