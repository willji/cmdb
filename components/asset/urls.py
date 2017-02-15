# encoding: utf8

from django.conf.urls import patterns, url
from rest_framework import routers
from components.asset import views

router = routers.DefaultRouter(trailing_slash=False)

router.register(r'asset', views.AssetViewSet)
router.register(r'assettype', views.AssetTypeViewSet)
router.register(r'assetstatus', views.AssetStatusViewSet)
router.register(r'assetspcification', views.AssetSpecificationViewSet)

urlpatterns = router.urls
