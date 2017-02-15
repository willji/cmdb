# encoding: utf8

from netaddr import IPAddress, IPNetwork
from rest_framework import viewsets
from rest_framework import permissions
from rest_framework import filters as rffilters
from rest_framework.exceptions import ParseError
from django.db.models import Prefetch, Count
from organization.environment.models import Location
from components.network.models import Ipv4Address
from components.asset.models import Asset
from components.application.models import Application, ApplicationGroup
from components.device import models
from components.device import serializers
import django_filters
import rest_framework_filters as filters


#region Filters

class AssetFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = Asset
        fileds = ['name',]

class PurposeFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = models.Purpose
        fileds = ['name',]

class LocationFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = Location
        fileds = ['name',]

class OSTypeFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = models.OSType
        fileds = ['name',]

class DeviceTypeFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = models.DeviceType
        fileds = ['name',]

class IPv4AddressFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = Ipv4Address
        fileds = ['name',]

class DeviceStatusFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')
    alias = django_filters.CharFilter('alias')

    class Meta:
        model = models.DeviceStatus
        fileds = ['name', 'alias']

class LBTypeFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')

    class Meta:
        model = models.LBType
        fileds = ['name',]

class DeviceFilter(filters.FilterSet):
    # REF:
    # http://stackoverflow.com/questions/26210217/how-to-use-modelmultiplechoicefilter

    asset = filters.RelatedFilter(AssetFilter, name='asset')
    purpose = filters.RelatedFilter(PurposeFilter, name='purpose')
    name = django_filters.CharFilter('name')
    rack = django_filters.CharFilter('rack')
    status = filters.RelatedFilter(DeviceStatusFilter, name='status')
    location = filters.RelatedFilter(LocationFilter, name='location')   
    ipaddresses = django_filters.ModelMultipleChoiceFilter(name='ipaddresses', to_field_name='name', lookup_type='in', queryset=Ipv4Address.objects.all())

    class Meta:
        model = models.Device

class PhysicalServerFilter(filters.FilterSet):
    asset = filters.RelatedFilter(AssetFilter, name='asset')
    purpose = filters.RelatedFilter(PurposeFilter, name='purpose')
    name = django_filters.CharFilter('name')
    rack = django_filters.CharFilter('rack')
    status = filters.RelatedFilter(DeviceStatusFilter, name='status')
    location = filters.RelatedFilter(LocationFilter, name='location')   
    ipaddresses = django_filters.ModelMultipleChoiceFilter(name='ipaddresses', to_field_name='name', lookup_type='in', queryset=Ipv4Address.objects.all())
    manager_ipaddresses = django_filters.ModelMultipleChoiceFilter(name='manager_ipaddresses', to_field_name='name', lookup_type='in', queryset=Ipv4Address.objects.all())

    class Meta:
        model = models.PhysicalServer

class VirtualMachineFilter(filters.FilterSet):
    asset = filters.RelatedFilter(AssetFilter, name='asset')
    purpose = filters.RelatedFilter(PurposeFilter, name='purpose')
    name = django_filters.CharFilter('name')
    host = filters.RelatedFilter(PhysicalServerFilter, name='host')
    status = filters.RelatedFilter(DeviceStatusFilter, name='status')
    ipaddresses = django_filters.ModelMultipleChoiceFilter(name='ipaddresses', to_field_name='name', lookup_type='in', queryset=Ipv4Address.objects.all())
    os = filters.RelatedFilter(OSTypeFilter, name='os')
    location = filters.RelatedFilter(LocationFilter, name='location')   

    class Meta:
        model = models.VirtualMachine

class LoadBalancerFilter(filters.FilterSet):
    asset = filters.RelatedFilter(AssetFilter, name='asset')
    purpose = filters.RelatedFilter(PurposeFilter, name='purpose')
    name = django_filters.CharFilter('name')
    rack = django_filters.CharFilter('rack')
    status = filters.RelatedFilter(DeviceStatusFilter, name='status')
    location = filters.RelatedFilter(LocationFilter, name='location')
    type = filters.RelatedFilter(LBTypeFilter, name='type')
    ipaddresses = django_filters.ModelMultipleChoiceFilter(name='ipaddresses', to_field_name='name', lookup_type='in', queryset=Ipv4Address.objects.all())

    class Meta:
        model = models.LoadBalancer

class LBGroupFilter(filters.FilterSet):
    name = django_filters.CharFilter('name')
    type = filters.RelatedFilter(LBTypeFilter, name='type')

    class Meta:
        model = models.LBGroup

class SwitchFilter(filters.FilterSet):
    asset = filters.RelatedFilter(AssetFilter, name='asset')
    purpose = filters.RelatedFilter(PurposeFilter, name='purpose')
    name = django_filters.CharFilter('name')
    rack = django_filters.CharFilter('rack')
    status = filters.RelatedFilter(DeviceStatusFilter, name='status')
    location = filters.RelatedFilter(LocationFilter, name='location')
    ipaddresses = django_filters.ModelMultipleChoiceFilter(name='ipaddresses', to_field_name='name', lookup_type='in', queryset=Ipv4Address.objects.all())

    class Meta:
        model = models.Switch

class VPNDeviceFilter(filters.FilterSet):
    asset = filters.RelatedFilter(AssetFilter, name='asset')
    purpose = filters.RelatedFilter(PurposeFilter, name='purpose')
    name = django_filters.CharFilter('name')
    rack = django_filters.CharFilter('rack')
    status = filters.RelatedFilter(DeviceStatusFilter, name='status')
    location = filters.RelatedFilter(LocationFilter, name='location')
    ipaddresses = django_filters.ModelMultipleChoiceFilter(name='ipaddresses', to_field_name='name', lookup_type='in', queryset=Ipv4Address.objects.all())

    class Meta:
        model = models.VPNDevice

class FirewallDeviceFilter(filters.FilterSet):
    asset = filters.RelatedFilter(AssetFilter, name='asset')
    purpose = filters.RelatedFilter(PurposeFilter, name='purpose')
    name = django_filters.CharFilter('name')
    rack = django_filters.CharFilter('rack')
    status = filters.RelatedFilter(DeviceStatusFilter, name='status')
    location = filters.RelatedFilter(LocationFilter, name='location')
    ipaddresses = django_filters.ModelMultipleChoiceFilter(name='ipaddresses', to_field_name='name', lookup_type='in', queryset=Ipv4Address.objects.all())

    class Meta:
        model = models.FirewallDevice

#endregion

#region Viewsets

class DeviceViewSet(viewsets.ReadOnlyModelViewSet):
    """
    This viewset automatically provides `list` actions.
    """
    queryset = models.Device.objects.select_related('asset', 'location', 'status', 'creator', 'last_modified_by')\
                                    .prefetch_related('ipaddresses')\
                                    .all()
    serializer_class = serializers.DeviceSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter, rffilters.OrderingFilter)
    filter_class = DeviceFilter
    search_fields = ('name', 'ipaddresses__name', 'purpose__name')
    ordering_fields = ('name', 'rack', 'unit_position')

class PhysicalServerViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = models.PhysicalServer.objects.select_related('asset', 'location', 'status', 'server_specification', 'os_type', 'creator', 'last_modified_by')\
                                    .prefetch_related('ipaddresses', 'virtualmachine_set', 'manager_ipaddresses')\
                                    .all()
    serializer_class = serializers.PhysicalServerSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter, rffilters.OrderingFilter)
    filter_class = PhysicalServerFilter
    search_fields = ('name', 'ipaddresses__name', 'purpose__name', 'manager_ipaddresses__name')
    ordering_fields = ('created_date',)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(PhysicalServerViewSet, self).perform_create(serializer)

class VirtualMachineViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """

    # Optimizing query speed.
    queryset_app = Application.objects.select_related()
    queryset_ip = Ipv4Address.objects.select_related()
    queryset_vlantags = models.VlanTag.objects.select_related()

    queryset = models.VirtualMachine.objects.select_related('asset', 'location', 'status', 'vcenter_server', 'vm_template', 'os', 'creator', 'last_modified_by')\
                                            .select_related('host', 'host__asset', 'host__location', 'host__server_specification', 'host__os_type')\
                                            .prefetch_related('host__ipaddresses')\
                                            .prefetch_related(Prefetch('applications', queryset = queryset_app))\
                                            .prefetch_related(Prefetch('ipaddresses', queryset = queryset_ip))\
                                            .prefetch_related(Prefetch('vlan_tags', queryset = queryset_vlantags))\
                                            .all()
    serializer_class = serializers.VirtualMachineSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter, rffilters.OrderingFilter, )
    filter_class = VirtualMachineFilter
    search_fields = ('name', 'ipaddresses__name', 'purpose__name')
    ordering_fields = ('name', 'status', 'created_date')

    def get_free_vm_ips(self, network):

        # get network addresses based on the network 10.10.101.0/24
        addresses = [x for x in list(network)]

        # Following code can get m2m fields, In this case, it should be applicationgroup and device.
        # m2m_fields = [x.name for x in Ipv4Address._meta.get_fields() if x.many_to_many]

        # REF:
        # https://docs.djangoproject.com/en/1.8/topics/db/aggregation/

        ips = Ipv4Address.objects.filter(name__in=addresses)\
                                 .annotate(Count('device'), Count('applicationgroup'))\
                                 .all()

        # using map function to figure out used ip addresses, for example:
        # device_ips = [1, 0, 1, 0]
        # appgrp_ips = [1, 1, 2, 0]
        # result = [1, 1, 1, 0]
        # note: one ip may be used by multiple devices or application groups, please pay attention to the function in map.
        device_ips = [ip.device__count for ip in ips]
        appgrp_ips = [ip.applicationgroup__count for ip in ips]
        result = map(lambda x, y: 1 if x + y > 0 else 0, device_ips, appgrp_ips)

        # calculate free vm ip address
        free_ips = [str(ips[index]) for index, value in enumerate(result) if value == 0]
        if '.'.join(str(network).split('.')[:3]) in ['10.10.101', '10.11.101', '10.12.99', '10.12.100', '10.12.101']:
            digits = [free_ip for free_ip in free_ips if int(free_ip.split('.')[-1]) in range(11, 251) and len(free_ip.split('.')[-1]) == 1]
            tens = [free_ip for free_ip in free_ips if int(free_ip.split('.')[-1]) in range(11, 251) and len(free_ip.split('.')[-1]) == 2]
            hundreds = [free_ip for free_ip in free_ips if int(free_ip.split('.')[-1]) in range(11, 251) and len(free_ip.split('.')[-1]) == 3]
            free_ips = digits + tens + hundreds
        else:
            digits = [free_ip for free_ip in free_ips if int(free_ip.split('.')[-1]) in range(11, 101) and len(free_ip.split('.')[-1]) == 1]
            tens = [free_ip for free_ip in free_ips if int(free_ip.split('.')[-1]) in range(11, 101) and len(free_ip.split('.')[-1]) == 2]
            hundreds = [free_ip for free_ip in free_ips if int(free_ip.split('.')[-1]) in range(11, 101) and len(free_ip.split('.')[-1]) == 3]
            free_ips = digits + tens + hundreds
        return free_ips

    def perform_create(self, serializer):

        host = models.PhysicalServer.objects.get(name=self.request.data['host'])

        # assign one or more ipaddress for an vm.
        if not self.request.data.has_key('ipaddresses'):
            # get host ip
            host_ips = [host.ipaddresses.get()]
            host_ips = [x.name for x in host_ips]
            
            # delete management/non vm network ips from list
            # vm should belong to 10.x.21.x to 10.x.100.x
            # disable following validation due to testing purposes.
            # vm_host_networks = range(21, 101)
            # host_ips = [x.name for x in host_ips if x.name.startswith('10') if int(x.name.split('.')[2]) in vm_host_networks]

            # do not assign ip address for vm if we cannot get host ip
            if not host_ips:
                raise Exception('host ip is invalid!')

            # ip addresses from 10.x.[21-100].[11 - 100] are used for virtual machine.

            # redis/mq/ha/nginx should assign ip address manually.
            # ip addresses from 10.x.[21-100].[131 - 150] are used for redis/mq.
            # ip addresses from 10.x.[21-100].[151 - 160] are used for ha/nginx.

            vm_ips = []
            for host_ip in host_ips:
                network_ip = ".".join(host_ip.split(".")[0:3]) + ".0/24"
                network = IPNetwork(network_ip)
                free_ips = self.get_free_vm_ips(network)
            
                # always assign first free ip from free ips list to vm, if host have two NICs here (dual-homed server),
                # we assume the vm on that host also have two.
                vm_ips.append(Ipv4Address.objects.get(name=free_ips[0]))
            

            name = None
            if not self.request.data.has_key('name'):
                prefix = 'WEB' if self.request.data['os'].upper().startswith('W') else 'Linux'
                name = "{0}-{1}".format(prefix, vm_ips[0].name)
            else:
                if self.request.data['name'] != '':
                    name = self.request.data['name']
                else:
                    prefix = 'WEB' if self.request.data['os'].upper().startswith('W') else 'Linux'
                    name = "{0}-{1}".format(prefix, vm_ips[0].name)
            
            serializer.validated_data['name'] = name
            serializer.validated_data['asset'] = host.asset
            serializer.validated_data['ipaddresses'] = vm_ips

            serializer.save(
                creator = self.request.user,
                last_modified_by = self.request.user
            )
        else:
            serializer.save(
                asset = host.asset,
                creator = self.request.user,
                last_modified_by = self.request.user
            )

        return super(VirtualMachineViewSet, self).perform_create(serializer)

class LoadBalancerViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """

    # Optimizing query speed.
    queryset_ip = Ipv4Address.objects.select_related()
    queryset_appgroup = ApplicationGroup.objects.select_related().prefetch_related('ipaddresses')

    queryset = models.LoadBalancer.objects.select_related('asset', 'location', 'status', 'type', 'creator', 'last_modified_by')\
                                          .prefetch_related(Prefetch('ipaddresses', queryset = queryset_ip))\
                                          .all()
    serializer_class = serializers.LoadBalancerSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_class = LoadBalancerFilter
    search_fields = ('name', 'purpose__name')

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(LoadBalancerViewSet, self).perform_create(serializer)

class SwitchViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = models.Switch.objects.select_related('asset', 'location', 'status', 'creator', 'last_modified_by')\
                                    .prefetch_related('ipaddresses')\
                                    .all()
    serializer_class = serializers.SwitchSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_class = SwitchFilter
    search_fields = ('name', 'purpose__name')

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(SwitchViewSet, self).perform_create(serializer)

class VPNDeviceViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = models.VPNDevice.objects.select_related('asset', 'location', 'status', 'creator', 'last_modified_by')\
                                       .prefetch_related('ipaddresses')\
                                       .all()
    serializer_class = serializers.VPNDeviceSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_class = VPNDeviceFilter
    search_fields = ('name', 'purpose__name')

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(VPNDeviceViewSet, self).perform_create(serializer)

class FirewallDeviceViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = models.FirewallDevice.objects.select_related('asset', 'location', 'status', 'creator', 'last_modified_by')\
                                            .prefetch_related('ipaddresses')\
                                            .all()
    serializer_class = serializers.FirewallDeviceSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_class = FirewallDeviceFilter
    search_fields = ('name', 'purpose__name')

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(FirewallDeviceViewSet, self).perform_create(serializer)

class OSTypeViewSet(viewsets.ModelViewSet):
    queryset = models.OSType.objects.select_related().all()
    serializer_class = serializers.OSTypeSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend,)
    filter_fields = ('name',)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(OSTypeViewSet, self).perform_create(serializer)

class LBTypeViewSet(viewsets.ModelViewSet):
    queryset = models.LBType.objects.select_related().all()
    serializer_class = serializers.LBTypeSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, )
    filter_fields = ('name',)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(LBTypeViewSet, self).perform_create(serializer)

class DeviceTypeViewSet(viewsets.ModelViewSet):
    queryset = models.DeviceType.objects.select_related().all()
    serializer_class = serializers.DeviceTypeSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, )
    filter_fields = ('name',)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(DeviceTypeViewSet, self).perform_create(serializer)

class DeviceStatusViewSet(viewsets.ModelViewSet):
    queryset = models.DeviceStatus.objects.select_related().all()
    serializer_class = serializers.DeviceStatusSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, )
    filter_fields = ('name','alias')

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(DeviceStatusViewSet, self).perform_create(serializer)

class VlanTagViewSet(viewsets.ModelViewSet):
    queryset = models.VlanTag.objects.select_related().all()
    serializer_class = serializers.VlanTagSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions, )

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_fields = ('name',)
    search_fields = ('name', )

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(VlanTagViewSet, self).perform_create(serializer)

#endregion

class LBGroupViewSet(viewsets.ModelViewSet):
    queryset = models.LBGroup.objects.select_related().all()
    serializer_class = serializers.LBGroupSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_class = LBGroupFilter
    search_fields = ('name', )

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(LBGroupViewSet, self).perform_create(serializer)

class PurposeViewSet(viewsets.ModelViewSet):
    queryset = models.Purpose.objects.select_related().all()
    serializer_class = serializers.PurposeSerializer

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    # Applies Filters
    filter_backends = (rffilters.DjangoFilterBackend, rffilters.SearchFilter)
    filter_class = PurposeFilter
    search_fields = ('name', )

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(PurposeViewSet, self).perform_create(serializer)

