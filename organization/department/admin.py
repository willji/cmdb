# encoding: utf8

from django.contrib import admin
from organization.department import models


admin.site.register(models.Department)
