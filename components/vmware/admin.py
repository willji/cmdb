# encoding: utf8

from django.contrib import admin
from components.vmware.models import VCenterServer, VMTemplate


admin.site.register(VCenterServer)
admin.site.register(VMTemplate)