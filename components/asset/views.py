# encoding: utf8

from rest_framework import viewsets
from rest_framework import filters as rffilters
from rest_framework import permissions
from components.asset.models import Asset, AssetStatus, AssetType, AssetSpecification
from components.asset.serializers import AssetSerializer, AssetStatusSerializer, AssetTypeSerializer, AssetSpecificationSerializer
import django_filters
import rest_framework_filters as filters


#region Filters

class AssetStatusFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = Asset
        fileds = ['name',]

class AssetTypeFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = AssetType
        fileds = ['name',]

class AssetFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')
    status = filters.RelatedFilter(AssetStatusFilter, name='status')
    type = filters.RelatedFilter(AssetTypeFilter, name='type')

    class Meta:
        model = Asset

#endregion

#region Views

class AssetViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = Asset.objects.select_related('type', 'status', 'specification', 'owner', 'department', 'creator', 'last_modified_by')\
                            .prefetch_related('dc_contact', 'vendor_contact')\
                            .all()
    serializer_class = AssetSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_class = AssetFilter

    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter, rffilters.OrderingFilter)
    filter_fields = ('name', 'asset_tag', 'type', 'status', 'serial_number', 'created_date')
    search_fields = ('name', 'asset_tag', 'serial_number', 'created_date')
    ordering_fields = ('name', 'asset_tag', 'serial_number', 'created_date')

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(AssetViewSet, self).perform_create(serializer)

class AssetTypeViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = AssetType.objects.select_related('creator', 'last_modified_by').all()
    serializer_class = AssetTypeSerializer

    # Applies permissions
    permission_classes = (permissions.IsAuthenticated,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_fields = ('name',)
    search_fields = ('name',)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(AssetTypeViewSet, self).perform_create(serializer)

class AssetSpecificationViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = AssetSpecification.objects.select_related('creator', 'last_modified_by').all()
    serializer_class = AssetSpecificationSerializer

    # Applies permissions
    permission_classes = (permissions.IsAuthenticated,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_fields = ('name',)
    search_fields = ('name',)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(AssetSpecificationViewSet, self).perform_create(serializer)

class AssetStatusViewSet(viewsets.ModelViewSet):
    queryset = AssetStatus.objects.select_related('creator', 'last_modified_by').all()
    serializer_class = AssetStatusSerializer

    # Applies permissions
    permission_classes = (permissions.IsAuthenticated,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_fields = ('name',)
    search_fields = ('name',)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(AssetStatusViewSet, self).perform_create(serializer)

#endregion
