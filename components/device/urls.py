# encoding: utf8

from django.conf.urls import url, include, patterns
from rest_framework import routers
from components.device import views


router = routers.DefaultRouter(trailing_slash=False)

router.register('ostype', views.OSTypeViewSet)
router.register('lbtype', views.LBTypeViewSet)
router.register('devicetype', views.DeviceTypeViewSet)
router.register('purpose', views.PurposeViewSet)
router.register('lbgroup', views.LBGroupViewSet)
router.register('devicestatus', views.DeviceStatusViewSet)
router.register('vlantags', views.VlanTagViewSet)
router.register('device', views.DeviceViewSet)
router.register('physicalserver', views.PhysicalServerViewSet)
router.register('switch', views.SwitchViewSet)
router.register('virtualmachine', views.VirtualMachineViewSet)
router.register('loadbalancer', views.LoadBalancerViewSet)
router.register('vpn', views.VPNDeviceViewSet)
router.register('firewall', views.FirewallDeviceViewSet)

urlpatterns = router.urls
