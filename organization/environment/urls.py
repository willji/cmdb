# encoding: utf8

from django.conf.urls import patterns, url
from rest_framework import routers
from organization.environment import views


router = routers.DefaultRouter(trailing_slash=False)

router.register(r'environment', views.EnvironmentViewSet)
router.register(r'location', views.LocationViewSet)

urlpatterns = router.urls