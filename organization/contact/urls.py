# encoding: utf8

from django.conf.urls import patterns, url
from rest_framework import routers
from organization.contact import views


router = routers.DefaultRouter(trailing_slash=False)

router.register(r'contact', views.PeopleViewSet)

urlpatterns = router.urls
