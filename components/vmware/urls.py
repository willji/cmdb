# encoding: utf8

from django.conf.urls import patterns, url
from rest_framework import routers
from components.vmware import views


router = routers.DefaultRouter(trailing_slash=False)

router.register(r'vcenterserver', views.VcenterServerViewSet)
router.register(r'vmtemplate', views.VmTemplateViewSet)

urlpatterns = router.urls