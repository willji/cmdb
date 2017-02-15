# encoding: utf8

from django.contrib import admin
from organization.environment.models import Environment, Location


admin.site.register(Environment)
admin.site.register(Location)