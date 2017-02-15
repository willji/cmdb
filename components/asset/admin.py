# encoding: utf8

from django.contrib import admin
from components.asset.models import AssetType, AssetSpecification, AssetStatus, Asset


admin.site.register(AssetType)
admin.site.register(AssetSpecification)
admin.site.register(AssetStatus)
admin.site.register(Asset)