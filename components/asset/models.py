# encoding: utf8

from django.db import models
from abstract.models import UniqueNameDescModel
from organization.contact.models import People
from organization.department.models import Department


class AssetType(UniqueNameDescModel):
    
    class Meta:
        ordering = ['name', ]

class AssetStatus(UniqueNameDescModel):
    
    class Meta:
        ordering = ['name', ]

class AssetSpecification(UniqueNameDescModel):
    
    class Meta:
        ordering = ['name', ]

class Asset(UniqueNameDescModel):
    asset_tag = models.CharField(max_length=255, help_text='Asset Tag')
    type = models.ForeignKey(AssetType, blank=True, related_name='type', help_text='Type of the asset')
    status = models.ForeignKey(AssetStatus, related_name="status")
    serial_number = models.CharField(null=True, blank=True, max_length=255, help_text='Serial Number')
    purpose = models.CharField(null=True, blank=True, max_length=255, help_text='Purpose of this asset.')
    value = models.PositiveIntegerField(help_text='Value of one asset.', null=True)
    dc_contact = models.ManyToManyField(People, blank=True, related_name='dc_contact', verbose_name='DataCenter Contact', help_text='Engineers for IDC operations.')
    vendor_contact = models.ManyToManyField(People, blank=True, related_name='vendor_contact', verbose_name='Vendor Contact', help_text='Engineers for maintaining server hardware.')
    hw_warranty_end = models.DateTimeField(null=True, help_text='Hardware warranty start date time for one asset.')
    sc_warranty_end = models.DateTimeField(null=True, help_text='Support contract warranty start date time for one asset.')
    owner = models.ForeignKey(People, null=True, blank=True, default=None, related_name='asset_owner', verbose_name='Asset Owner', help_text='Owner of one asset.')
    department = models.ForeignKey(Department, null=True, blank=True, default=None, related_name='asset_owner', verbose_name='Asset Department', help_text='Department of one asset.')
    specification = models.ForeignKey(AssetSpecification, null=True, blank=True, default=None, help_text='Specification of one server', related_name="asset_spec")
    stock_date = models.DateTimeField(null=True, help_text='Stock date time for one asset.')

    class Meta:
        ordering = ['asset_tag', ]