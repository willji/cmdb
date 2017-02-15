# encoding: utf8

from django.contrib import admin
from components.device import models


class LBGroupAdmin(admin.ModelAdmin):
    list_display = ('name', 'creator', 'last_modified_by', 'created_date', 'modified_date')
    fields = ('name', 'loadbalancers')
    search_fields = ('name',)

admin.site.register(models.OSType)
admin.site.register(models.LBType)
admin.site.register(models.DeviceStatus)
admin.site.register(models.VlanTag)
admin.site.register(models.Device)
admin.site.register(models.PhysicalServer)
admin.site.register(models.VirtualMachine)
admin.site.register(models.Switch)
admin.site.register(models.VPNDevice)
admin.site.register(models.FirewallDevice)
admin.site.register(models.LBGroup, LBGroupAdmin)




