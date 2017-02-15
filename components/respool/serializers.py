# encoding: utf8

from rest_framework import serializers
from abstract.serializers import CommonHyperlinkedModelSerializer
from components.device.models import VirtualMachine, PhysicalServer
from components.respool.models import VirtualMachineResourcePool, PhysicalServerResourcePool
from rest_framework.validators import UniqueValidator


class VirtualMachineResourcePoolSerializer(CommonHyperlinkedModelSerializer):

    virtualmachine = serializers.SlugRelatedField(queryset=VirtualMachine.objects.all(), slug_field='name')

    vcenterserver = serializers.SerializerMethodField(read_only=True)
    ipaddresses = serializers.SerializerMethodField(read_only=True)
    os = serializers.SerializerMethodField(read_only=True)
    location = serializers.SerializerMethodField(read_only=True)
    rack = serializers.SerializerMethodField(read_only=True)
    virtual_memory = serializers.SerializerMethodField(read_only=True)
    virtual_storage = serializers.SerializerMethodField(read_only=True)
    host = serializers.SerializerMethodField(read_only=True)
    host_ips = serializers.SerializerMethodField(read_only=True)
    status = serializers.SerializerMethodField(read_only=True)
    purpose = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = VirtualMachineResourcePool

    def get_vcenterserver(self, obj):
        return obj.virtualmachine.vcenter_server.name
    
    def get_ipaddresses(self, obj):
        r = []
        for ip in obj.virtualmachine.ipaddresses.all():
            r.append(ip.name)
        return r
    
    def get_os(self, obj):
        return obj.virtualmachine.os.name
    
    def get_purpose(self, obj):
        if obj.virtualmachine.purpose:
            return obj.virtualmachine.purpose.name
        else:
            return None
    
    def get_rack(self, obj):
        return obj.virtualmachine.host.rack
    
    def get_virtual_memory(self, obj):
        return obj.virtualmachine.virtual_memory
    
    def get_virtual_storage(self, obj):
        return obj.virtualmachine.virtual_storage
    
    def get_status(self, obj):
        return obj.virtualmachine.status.name
    
    def get_host(self, obj):
        return obj.virtualmachine.host.name
    
    def get_host_ips(self, obj):
        r = []
        for ip in obj.virtualmachine.host.ipaddresses.all():
            r.append(ip.name)
        return r
    
    def get_location(self, obj):
        if obj.virtualmachine.location:
            return obj.virtualmachine.location.name

class PhysicalServerResourcePoolSerializer(CommonHyperlinkedModelSerializer):

    physicalserver = serializers.SlugRelatedField(queryset=PhysicalServer.objects.all(), slug_field='name')

    visible_label = serializers.SerializerMethodField(read_only=True)
    location = serializers.SerializerMethodField(read_only=True)
    rack = serializers.SerializerMethodField(read_only=True)
    status = serializers.SerializerMethodField(read_only=True)
    os = serializers.SerializerMethodField(read_only=True)
    server_specification = serializers.SerializerMethodField(read_only=True)
    ipaddresses = serializers.SerializerMethodField(read_only=True)
    virtual_machines = serializers.SerializerMethodField(read_only=True)
    created_date = serializers.SerializerMethodField(read_only=True)
    description = serializers.SerializerMethodField(read_only=True)
    purpose = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = PhysicalServerResourcePool

    def get_visible_label(self, obj):
        return obj.physicalserver.visible_label
    
    def get_location(self, obj):
        return obj.physicalserver.location.name
    
    def get_rack(self, obj):
        return obj.physicalserver.rack
    
    def get_purpose(self, obj):
        if obj.physicalserver.purpose:
            return obj.physicalserver.purpose.name
        else:
            return None
    
    def get_status(self, obj):
        return obj.physicalserver.status.name
    
    def get_os(self, obj):
        return obj.physicalserver.os_type.name
    
    def get_server_specification(self, obj):
        return obj.physicalserver.server_specification.name
    
    def get_ipaddresses(self, obj):
        return [ip.name for ip in obj.physicalserver.ipaddresses.all()]
    
    def get_virtual_machines(self, obj):
        return [x.name for x in obj.physicalserver.virtualmachine_set.all()]
    
    def get_created_date(self, obj):
        return obj.physicalserver.created_date
    
    def get_description(self, obj):
        return obj.physicalserver.description
