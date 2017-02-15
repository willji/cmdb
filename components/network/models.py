# encoding: utf8

from django.db import models
from abstract.models import UniqueNameDescModel


class Ipv4Address(UniqueNameDescModel):
    
    class Meta:
        ordering = ['name', ]

class Ipv4Network(UniqueNameDescModel):
    gateway = models.CharField(max_length=18, null=True)

    class Meta:
        ordering = ['name', ]