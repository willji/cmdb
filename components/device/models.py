# encoding: utf8

from django.db import models
from abstract.models import NameModel, NameDescModel, UniqueNameDescModel
from organization.department.models import Department
from organization.environment.models import Location
from components.application.models import Application
from components.asset.models import Asset, AssetSpecification
from components.network.models import Ipv4Address
from components.vmware.models import VCenterServer, VMTemplate


class OSType(UniqueNameDescModel):

    class Meta:
        ordering = ['name', ]

class LBType(UniqueNameDescModel):
    
    class Meta:
        ordering = ['name', ]

class DeviceType(UniqueNameDescModel):
    
    class Meta:
        ordering = ['name', ]

class Purpose(UniqueNameDescModel):
    
    class Meta:
        ordering = ['name', ]

class DeviceStatus(UniqueNameDescModel):
  
    alias = models.CharField(max_length=10)

    class Meta:
        ordering = ['name', ]

class VlanTag(UniqueNameDescModel):
    
    class Meta:
        ordering = ['name', ]

class Device(UniqueNameDescModel):
    # A base model for other type of devices to be inherited from.
    # REF https://docs.djangoproject.com/en/1.9/topics/db/models/#multi-table-inheritance

    asset = models.ForeignKey(Asset, related_name='%(app_label)s_%(class)s_related', help_text='An instance of one asset')
    location = models.ForeignKey(Location, null=True, blank=True, related_name='%(app_label)s_%(class)s_related', help_text='Geo-location of one device, like Shanghai Waigaoqiao IDC')
    rack = models.CharField(max_length=20, default='', null=True, blank=True, db_index=True, help_text='Rack location of one device, like RACK6')
    unit_position = models.PositiveSmallIntegerField(default=1, db_index=True, help_text='Unit location of one device in one rack, like 16')
    unit_height = models.PositiveSmallIntegerField(default=1, help_text='Unit height of one device, like 1/2/4')
    ipaddresses = models.ManyToManyField(Ipv4Address, blank=True, help_text='IP addresses of one device')
    status = models.ForeignKey(DeviceStatus, null=True, default=None, blank=True, help_text='Status of one device, like UP, Malfunction, Down')
    visible_label = models.CharField(max_length=40, default='', null=True, blank=True)  
    device_type = models.ForeignKey(DeviceType, null=True, default=None, blank=True, help_text='Type of one device')
    purpose = models.ForeignKey(Purpose, null=True, default=None, blank=True, help_text='Purpose of one device')

    class Meta:
        ordering = ['name', 'rack', 'unit_position', ]

class PhysicalServer(Device):
    raid_types = (
        ('RAID01', 'RAID 0 + 1'),
        ('RAID10', 'RAID 1 + 0'),
        ('RAID0', 'RAID 0'),
        ('RAID1', 'RAID 1'),
        ('RAID2', 'RAID 2'),
        ('RAID3', 'RAID 3'),
        ('RAID4', 'RAID 4'),
        ('RAID5', 'RAID 5'),
        ('RAID6', 'RAID 6'),
    )

    cpu = models.PositiveIntegerField(default=1, help_text='Number of logical cores')
    memory = models.BigIntegerField(default=274877906944, help_text='Number of installed memory, default is 256GB')
    storage_capacity = models.BigIntegerField(default=1099511627776, help_text='Number of storage capacity, default is 1TB')
    server_specification = models.ForeignKey(AssetSpecification, help_text='Specification of one server, like HP Proliant DL380')
    os_type = models.ForeignKey(OSType, related_name='os_type')
    raid_type = models.CharField(max_length=20, choices=raid_types, help_text='Type of RAID, like RAID10')
    manager_ipaddresses = models.ManyToManyField(Ipv4Address, blank=True, help_text='manager IP addresses of one device')

    class Meta:
        ordering = ['name', 'rack', 'unit_position']

class VirtualMachine(Device):
    vcenter_server = models.ForeignKey(VCenterServer, null=True, blank=True, help_text='VCenter Server Name')
    vm_template = models.ForeignKey(VMTemplate, null=True, blank=True, help_text='VM Template Name')
    host = models.ForeignKey(PhysicalServer, help_text='Physical server name')
    os = models.ForeignKey(OSType, help_text='Operation System name')
    virtual_cpu = models.PositiveIntegerField(default=2, help_text='Number of virtual CPU')
    virtual_memory = models.BigIntegerField(default=17179869184, help_text='Number of virtual memory, in GB')
    virtual_storage = models.BigIntegerField(default=17179869184, help_text='Number of virtual HDD capacity, in GB')
    vlan_tags = models.ManyToManyField(VlanTag, blank=True, help_text='Tag name of one VLAN.')
    applications = models.ManyToManyField(Application, blank=True, help_text='Applications that are deployed in one VM')

    class Meta:
        ordering = ['name', 'rack', 'unit_position']

class LoadBalancer(Device):
    type = models.ForeignKey(LBType, null=True, blank=True, help_text='Type of load balancers, like NetScaler, HAProxy, NGINX')
    is_master = models.BooleanField(default=False)

    class Meta:
        ordering = ['name', 'rack', 'unit_position']

class Switch(Device):

    class Meta:
        ordering = ['name', 'rack', 'unit_position']

class VPNDevice(Device):

    class Meta:
        ordering = ['name', 'rack', 'unit_position']

class FirewallDevice(Device):

    class Meta:
        ordering = ['name', 'rack', 'unit_position']

class LBGroup(UniqueNameDescModel):
    loadbalancers = models.ManyToManyField(LoadBalancer, blank=True)
    type = models.ForeignKey(LBType, null=True, blank=True, help_text='Type of load balancers, like NetScaler, HAProxy, NGINX')
    
    class Meta:
        ordering = ['name', ]

