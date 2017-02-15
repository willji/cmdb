# encoding: utf8

from rest_framework import filters
from rest_framework import permissions
from rest_framework import viewsets
from components.vmware import models
from components.vmware import serializers


class VcenterServerViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = models.VCenterServer.objects.select_related('creator', 'last_modified_by').all()
    serializer_class = serializers.VCenterServerSerializer

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
        return super(VcenterServerViewSet, self).perform_create(serializer)

class VmTemplateViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = models.VMTemplate.objects.select_related('creator', 'last_modified_by').all()
    serializer_class = serializers.VMTemplateSerializer

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
        return super(VmTemplateViewSet, self).perform_create(serializer)
