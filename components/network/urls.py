# encoding: utf8

from django.conf.urls import patterns, url
from rest_framework import routers
from components.network import views


router = routers.DefaultRouter(trailing_slash=False)

router.register(r'ipv4address', views.Ipv4AddressViewSet)
router.register(r'ipv4network', views.Ipv4NetworkViewSet)

urlpatterns = router.urls