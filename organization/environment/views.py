# encoding: utf8

from rest_framework import filters
from rest_framework import permissions
from rest_framework import viewsets
from organization.environment import models
from organization.environment import serializers


class EnvironmentViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = models.Environment.objects.all()
    serializer_class = serializers.EnvironmentSeriliazer

    # Applies Filters
    filter_backends = (filters.DjangoFilterBackend,)
    filter_fields = ('name',)

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(EnvironmentViewSet, self).perform_create(serializer)

class LocationViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = models.Location.objects.all()
    serializer_class = serializers.LocationSerializer

    # Applies Filters
    filter_backends = (filters.DjangoFilterBackend,)
    filter_fields = ('name',)

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(LocationViewSet, self).perform_create(serializer)
