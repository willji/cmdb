#encoding: utf8

from django.db.models import Prefetch
from rest_framework import viewsets, mixins
from rest_framework import permissions
from rest_framework import filters as rffilters
from organization.department.models import Department
from organization.environment.models import Environment, Location
from components.network.models import Ipv4Address
from components.application import models, serializers
import django_filters
import rest_framework_filters as filters


#region Filters

class DepartmentFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = Department
        fileds = ['name']

class EnvironmentFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = Environment
        fileds = ['name']

class LocationFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = Location
        fileds = ['name']

class ApplicationFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')
    type = django_filters.CharFilter('type')
    department = filters.RelatedFilter(DepartmentFilter, name='department')

    class Meta:
        model = models.Application

class ApplicationGroupFilter(filters.FilterSet):
    application = filters.RelatedFilter(ApplicationFilter, name='application')
    environment = filters.RelatedFilter(EnvironmentFilter, name='environment')
    location = filters.RelatedFilter(LocationFilter, name='location')
    ipaddresses = django_filters.ModelMultipleChoiceFilter(name='ipaddresses', to_field_name='name', lookup_type='in', queryset=Ipv4Address.objects.all())

    class Meta:
        model = models.ApplicationGroup

class ApplicationHistoryFilter(filters.FilterSet):
    application_group = filters.RelatedFilter(ApplicationGroupFilter, name='application_group')
    version = django_filters.CharFilter('version')

    class Meta:
        model = models.ApplicationHistory

#endregion


#region ViewSets

class ApplicationViewSet(viewsets.ModelViewSet):
    agQueryset = models.ApplicationGroup.objects.select_related().prefetch_related('ipaddresses').all()
    queryset = models.Application.objects.select_related('department', 'owner', 'backup_owner', 'backup2_owner', 'ops_owner','creator', 'last_modified_by')\
                                         .prefetch_related(Prefetch('applicationgroup_set', queryset = agQueryset))\
                                         .all()
    serializer_class = serializers.ApplicationSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_class = ApplicationFilter
    search_fields = ('name', 'owner__chinese_name', 'backup_owner__chinese_name', 'backup2_owner__chinese_name', 'ops_owner__chinese_name')

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(ApplicationViewSet, self).perform_create(serializer)

class ApplicationGroupViewSet(viewsets.ModelViewSet):
    queryset = models.ApplicationGroup.objects.select_related('application', 'environment', 'location', 'creator', 'last_modified_by')\
                                              .select_related('application__department', 'application__type')\
                                              .select_related('application__owner', 'application__backup_owner', 'application__backup2_owner','application__ops_owner')\
                                              .prefetch_related('ipaddresses')\
                                              .prefetch_related('lbgroup')\
                                              .all()
    serializer_class = serializers.ApplicationGroupSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_class = ApplicationGroupFilter
    search_fields = ('application__name', 'ipaddresses__name')

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(ApplicationGroupViewSet, self).perform_create(serializer)

class ApplicationHistoryViewSet(viewsets.ModelViewSet):
    queryset = models.ApplicationHistory.objects.select_related('application_group', 'creator', 'last_modified_by')\
                                                .select_related('application_group__environment', 'application_group__location')\
                                                .select_related('application_group__application__owner')\
                                                .select_related('application_group__application__backup_owner')\
                                                .select_related('application_group__application__backup2_owner')\
                                                .select_related('application_group__application__ops_owner')\
                                                .select_related('application_group__application__department')\
                                                .prefetch_related('application_group__ipaddresses')\
                                                .prefetch_related('application_group__lbgroup')\
                                                .all()
    serializer_class = serializers.ApplicationHistorySerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_class = ApplicationHistoryFilter

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(ApplicationHistoryViewSet, self).perform_create(serializer)

class WarmupUrlViewSet(viewsets.ModelViewSet):
    queryset = models.WarmupUrl.objects.select_related('creator', 'last_modified_by').all()
    serializer_class = serializers.WarmupUrlSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_fields = ('name',)
    search_fields = ('name',)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(WarmupUrlViewSet, self).perform_create(serializer)

class StatusCodeViewSet(viewsets.ModelViewSet):
    queryset = models.StatusCode.objects.select_related('creator', 'last_modified_by').all()
    serializer_class = serializers.StatusCodeSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_fields = ('name',)
    search_fields = ('name',)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(StatusCodeViewSet, self).perform_create(serializer)

class ApplicationWarmupUrlViewSet(viewsets.ModelViewSet):
    queryset = models.ApplicationWarmupUrl.objects.select_related('creator', 'last_modified_by').all()
    serializer_class = serializers.ApplicationWarmupUrlSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_fields = ('application__name', 'warmup_url__name')
    search_fields = ('application__name',)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(ApplicationWarmupUrlViewSet, self).perform_create(serializer)

#endregion
