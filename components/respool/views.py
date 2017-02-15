# -*- encoding: utf-8 -*-

from rest_framework import filters as rffilters
from rest_framework import viewsets
from rest_framework import permissions
from django.db.models import Prefetch
from components.device.models import VirtualMachine, PhysicalServer
from components.application.models import Application
from components.respool.models import VirtualMachineResourcePool, PhysicalServerResourcePool
from components.respool.serializers import VirtualMachineResourcePoolSerializer, PhysicalServerResourcePoolSerializer
import rest_framework_filters as filters

class VirtualMachineResourcePoolFilter(filters.FilterSet):
    
    class Meta:
        model = VirtualMachineResourcePool
        fields = ['virtualmachine__purpose__name', 'virtualmachine__name', 'virtualmachine__status__name', 'virtualmachine__rack', 'virtualmachine__os__name', 'virtualmachine__location__name', 'virtualmachine__vcenter_server__name', 'virtualmachine__ipaddresses__name']

class PhysicalServerResourcePoolFilter(filters.FilterSet):
    
    class Meta:
        model = PhysicalServerResourcePool
        fields = ['physicalserver__purpose__name', 'physicalserver__name', 'physicalserver__status__name', 'physicalserver__rack', 'physicalserver__location__name', 'physicalserver__ipaddresses__name']

class VirtualMachineResourcePoolViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """

    # REF:
    # https://docs.djangoproject.com/en/1.9/ref/models/querysets/#defer
    # https://docs.djangoproject.com/en/1.9/ref/models/querysets/#django.db.models.query.QuerySet.only
    queryset_vms = VirtualMachine.objects.all()
    queryset = VirtualMachineResourcePool.objects.prefetch_related(Prefetch('virtualmachine', queryset = queryset_vms)).all()
    serializer_class = VirtualMachineResourcePoolSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter, rffilters.OrderingFilter)
    filter_class = VirtualMachineResourcePoolFilter
    search_fields = ('virtualmachine__name', 'virtualmachine__rack', 'virtualmachine__vcenter_server__name', 'virtualmachine__os__name', 'virtualmachine__location__name', 'virtualmachine__ipaddresses__name', 'virtualmachine__status__name')
    ordering_fields = ('created_date', 'modified_date')

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(VirtualMachineResourcePoolViewSet, self).perform_create(serializer)

class PhysicalServerResourcePoolViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """

    # REF:
    # https://docs.djangoproject.com/en/1.9/ref/models/querysets/#defer
    # https://docs.djangoproject.com/en/1.9/ref/models/querysets/#django.db.models.query.QuerySet.only
    queryset_pss = PhysicalServer.objects.all()
    queryset = PhysicalServerResourcePool.objects.prefetch_related(Prefetch('physicalserver', queryset = queryset_pss)).all()
    serializer_class = PhysicalServerResourcePoolSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter, rffilters.OrderingFilter)
    filter_class = PhysicalServerResourcePoolFilter
    search_fields = ('physicalserver__name', 'physicalserver__status__name', 'physicalserver__rack', 'physicalserver__location__name', 'physicalserver__ipaddresses__name')
    ordering_fields = ('created_date', 'modified_date')

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(PhysicalServerResourcePoolViewSet, self).perform_create(serializer)
