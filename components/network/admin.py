# encoding: utf8

from django.contrib import admin
from components.network.models import Ipv4Address, Ipv4Network


admin.site.register(Ipv4Address)
admin.site.register(Ipv4Network)
