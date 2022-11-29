from newsfeeds.api.serializers import NewsFeedSerializer
from newsfeeds.models import NewsFeed
from newsfeeds.services import NewsFeedService
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from utils.paginations import EndlessPagination

class NewsFeedViewSet(viewsets.GenericViewSet):
    queryset = NewsFeed.objects.all() # Added to avoid newsfeeds api failure
    permission_classes = [IsAuthenticated]
    pagination_class = EndlessPagination

    def list(self, request):
        newsfeeds = NewsFeedService.get_cached_newsfeeds(request.user.id)
        page = self.paginate_queryset(newsfeeds)
        serializer = NewsFeedSerializer(
            page,
            context={'request': request},
            many=True,
        )
        return self.get_paginated_response(serializer.data)
