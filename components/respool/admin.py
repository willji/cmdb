from django.contrib import admin
from components.respool.models import VirtualMachineResourcePool, PhysicalServerResourcePool

admin.site.register(VirtualMachineResourcePool)
admin.site.register(PhysicalServerResourcePool)
