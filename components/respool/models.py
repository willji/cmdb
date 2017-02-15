# -*- encoding: utf8 -*-
from django.db import models
from abstract.models import CommonModel
from components.device.models import VirtualMachine, PhysicalServer

class VirtualMachineResourcePool(CommonModel):
    virtualmachine = models.OneToOneField(VirtualMachine)

class PhysicalServerResourcePool(CommonModel):
    physicalserver = models.OneToOneField(PhysicalServer)
