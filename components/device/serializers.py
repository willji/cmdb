# encoding: utf8

from rest_framework import serializers
from rest_framework.exceptions import ParseError
from django.db.models.query_utils import Q
from django.db.models import Prefetch
from abstract.serializers import CommonHyperlinkedModelSerializer
from organization.environment.models import Location
from components.asset.models import Asset, AssetSpecification
from components.device import models
from components.network.models import Ipv4Address
from components.application.models import Application, ApplicationGroup, ApplicationWarmupUrl
from components.application.serializers import ApplicationSerializer
from components.vmware.models import VCenterServer, VMTemplate


# NOTES:
# There is an open issue when rendering HTML forms for many IPv4Address, check below.
# https://github.com/tomchristie/django-rest-framework/issues/3329

class PurposeSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.Purpose

class OSTypeSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.OSType

class LBTypeSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.LBType

class DeviceTypeSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.DeviceType

class DeviceStatusSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.DeviceStatus

class VlanTagSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.VlanTag

class DeviceSerializer(CommonHyperlinkedModelSerializer):

    # visible label is not required.
    visible_label = serializers.CharField(required=False)

    asset = serializers.SlugRelatedField(queryset=Asset.objects.all(), slug_field='name')
    location = serializers.SlugRelatedField(queryset=Location.objects.all(), slug_field='name')
    ipaddresses = serializers.SlugRelatedField(many=True, queryset=Ipv4Address.objects.all(), slug_field='name')
    status = serializers.SlugRelatedField(queryset=models.DeviceStatus.objects.all(), slug_field='name')
    device_type = serializers.SlugRelatedField(queryset=models.DeviceType.objects.all(), slug_field='name')
    purpose = serializers.SlugRelatedField(queryset=models.Purpose.objects.all(), slug_field='name', allow_null=True)

    class Meta:
        model = models.Device

class PhysicalServerSerializer(CommonHyperlinkedModelSerializer):
    
    # Fields from Device model.
    asset = serializers.SlugRelatedField(queryset=Asset.objects.all(), slug_field='name')
    status = serializers.SlugRelatedField(queryset=models.DeviceStatus.objects.all(), slug_field='name')
    location = serializers.SlugRelatedField(queryset=Location.objects.all(), slug_field='name')
    ipaddresses = serializers.SlugRelatedField(many=True, queryset=Ipv4Address.objects.all(), slug_field='name')
    manager_ipaddresses = serializers.SlugRelatedField(many=True, queryset=Ipv4Address.objects.all(), slug_field='name')
    device_type = serializers.SlugRelatedField(queryset=models.DeviceType.objects.all(), slug_field='name')
    purpose = serializers.SlugRelatedField(queryset=models.Purpose.objects.all(), slug_field='name', allow_null=True)

    # Fields from PhysicalServer model.
    os_type = serializers.SlugRelatedField(queryset=models.OSType.objects.all(), slug_field='name')
    server_specification = serializers.SlugRelatedField(queryset=AssetSpecification.objects.all(), slug_field='name')

    # Using SerializerMethodField to get virtual machines for one physical server (host).
    # REF: http://www.django-rest-framework.org/api-guide/fields/#serializermethodfield
    virtual_machines = serializers.SerializerMethodField(read_only=True)
    
    class Meta:
        model = models.PhysicalServer

    def get_virtual_machines(self, obj):
        # REF:
        # https://docs.djangoproject.com/en/1.9/ref/models/relations/#related-objects-reference
        # http://stackoverflow.com/questions/23353474/foreignrelatedobjectsdescriptor-object-has-no-attribute-all
        return [x.name for x in obj.virtualmachine_set.all()]

class VirtualMachineSerializer(CommonHyperlinkedModelSerializer):

    # generate vm name if name is missing.
    name = serializers.CharField(required=False)

    vcenter_server = serializers.SlugRelatedField(queryset=VCenterServer.objects.all(), slug_field='name')
    vm_template = serializers.SlugRelatedField(queryset=VMTemplate.objects.all(), slug_field='name')
    host = serializers.SlugRelatedField(queryset=models.PhysicalServer.objects.all(), slug_field='name')
    os = serializers.SlugRelatedField(queryset=models.OSType.objects.all(), slug_field='name')
    ipaddresses = serializers.SlugRelatedField(many=True, queryset=Ipv4Address.objects.all(), slug_field='name', allow_null=True, required=False)
    status = serializers.SlugRelatedField(queryset=models.DeviceStatus.objects.all(), slug_field='name')
    vlan_tags = serializers.SlugRelatedField(many=True, queryset=models.VlanTag.objects.all(), slug_field='name', allow_null=True, required=False)
    location = serializers.SlugRelatedField(queryset=Location.objects.all(), slug_field='name', allow_null=True)
    device_type = serializers.SlugRelatedField(queryset=models.DeviceType.objects.all(), slug_field='name')
    purpose = serializers.SlugRelatedField(queryset=models.Purpose.objects.all(), slug_field='name', allow_null=True)

    # Asset, location, rack, unit position should be inherited from host.
    # One virtual machine inherits the asset name from host. 
    # Unit height should be set to zero because it is a virtual machine.
    asset = serializers.SerializerMethodField(read_only=True)
    rack = serializers.SerializerMethodField(read_only=True)
    unit_position = serializers.SerializerMethodField(read_only=True)
    unit_height = serializers.SerializerMethodField(read_only=True)
    host_ips = serializers.SerializerMethodField(read_only=True)
    applications = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = models.VirtualMachine

    def get_asset(self, obj):
        return obj.host.asset.name

    def get_rack(self, obj):
        return obj.host.rack

    def get_unit_position(self, obj):
        return obj.host.unit_position
    
    def get_unit_height(self, obj):
        return 0

    def get_host_ips(self, obj):
        return [x.name for x in obj.host.ipaddresses.all()]

    def get_applications(self, obj):
        results = []
        for ip in obj.ipaddresses.all():
            for appgroup in ip.applicationgroup_set.all():
                results.append(appgroup.application.name)
        return results

class LoadBalancerSerializer(CommonHyperlinkedModelSerializer):

    # Fields from Device model.
    asset = serializers.SlugRelatedField(queryset=Asset.objects.all(), slug_field='name')
    status = serializers.SlugRelatedField(queryset=models.DeviceStatus.objects.all(), slug_field='name')
    location = serializers.SlugRelatedField(queryset=Location.objects.all(), slug_field='name', allow_null=True)
    ipaddresses = serializers.SlugRelatedField(many=True, queryset=Ipv4Address.objects.all(), slug_field='name')
    device_type = serializers.SlugRelatedField(queryset=models.DeviceType.objects.all(), slug_field='name')
    purpose = serializers.SlugRelatedField(queryset=models.Purpose.objects.all(), slug_field='name', allow_null=True)
    
    # Fields for LoadBalancer model.
    type = serializers.SlugRelatedField(queryset=models.LBType.objects.all(), slug_field='name', allow_null=True)

    # Using SerializerMethodField to get application groups.
    # REF: http://www.django-rest-framework.org/api-guide/fields/#serializermethodfield
    #app_groups = serializers.SerializerMethodField(read_only=True)
    
    class Meta:
        model = models.LoadBalancer

    def get_app_groups(self, obj):
        # REF:
        # https://docs.djangoproject.com/en/1.9/ref/models/relations/#related-objects-reference
        # http://stackoverflow.com/questions/23353474/foreignrelatedobjectsdescriptor-object-has-no-attribute-all

        results = dict()
        for appgroup in obj.applicationgroup_set.all():
            ipList = []
            name = "{0}_{1}_{2}".format(appgroup.application.name, appgroup.environment.name, appgroup.location.pk)
            for ip in appgroup.ipaddresses.all():
                ipList.append(ip.name)
            results[name] = ipList
        return results

class SwitchSerializer(CommonHyperlinkedModelSerializer):

    # Fields from Device model.
    asset = serializers.SlugRelatedField(queryset=Asset.objects.all(), slug_field='name')
    status = serializers.SlugRelatedField(queryset=models.DeviceStatus.objects.all(), slug_field='name')
    location = serializers.SlugRelatedField(queryset=Location.objects.all(), slug_field='name')
    ipaddresses = serializers.SlugRelatedField(many=True, queryset=Ipv4Address.objects.all(), slug_field='name')
    device_type = serializers.SlugRelatedField(queryset=models.DeviceType.objects.all(), slug_field='name')
    purpose = serializers.SlugRelatedField(queryset=models.Purpose.objects.all(), slug_field='name', allow_null=True)

    class Meta:
        model = models.Switch

class VPNDeviceSerializer(CommonHyperlinkedModelSerializer):

    # Fields from Device model.
    asset = serializers.SlugRelatedField(queryset=Asset.objects.all(), slug_field='name')
    status = serializers.SlugRelatedField(queryset=models.DeviceStatus.objects.all(), slug_field='name')
    location = serializers.SlugRelatedField(queryset=Location.objects.all(), slug_field='name')
    ipaddresses = serializers.SlugRelatedField(many=True, queryset=Ipv4Address.objects.all(), slug_field='name')
    device_type = serializers.SlugRelatedField(queryset=models.DeviceType.objects.all(), slug_field='name')
    purpose = serializers.SlugRelatedField(queryset=models.Purpose.objects.all(), slug_field='name', allow_null=True)

    class Meta:
        model = models.VPNDevice

class FirewallDeviceSerializer(CommonHyperlinkedModelSerializer):

    # Fields from Device model.
    asset = serializers.SlugRelatedField(queryset=Asset.objects.all(), slug_field='name')
    status = serializers.SlugRelatedField(queryset=models.DeviceStatus.objects.all(), slug_field='name')
    location = serializers.SlugRelatedField(queryset=Location.objects.all(), slug_field='name')
    ipaddresses = serializers.SlugRelatedField(many=True, queryset=Ipv4Address.objects.all(), slug_field='name')
    device_type = serializers.SlugRelatedField(queryset=models.DeviceType.objects.all(), slug_field='name')
    purpose = serializers.SlugRelatedField(queryset=models.Purpose.objects.all(), slug_field='name', allow_null=True)

    class Meta:
        model = models.FirewallDevice

class LBGroupSerializer(CommonHyperlinkedModelSerializer):

    loadbalancers = serializers.SlugRelatedField(many=True, queryset=models.LoadBalancer.objects.all(), slug_field='name', allow_null=True, required=False)
    type = serializers.SlugRelatedField(queryset=models.LBType.objects.all(), slug_field='name', allow_null=True)

    ipaddresses = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = models.LBGroup

    def get_ipaddresses(self, obj):
        results = []
        for x in obj.loadbalancers.all():
            for i in x.ipaddresses.all():
                results.append(i.name)
        return results
