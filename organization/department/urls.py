# encoding: utf8

from django.conf.urls import patterns, url
from rest_framework import routers
from organization.department import views


router = routers.DefaultRouter(trailing_slash=False)

router.register(r'department', views.DepartmentViewSet)

urlpatterns = router.urls
