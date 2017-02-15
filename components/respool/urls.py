from django.conf.urls import url, include
from rest_framework import routers
from components.respool import views


router = routers.DefaultRouter(trailing_slash=False)

router.register('virtualmachineresourcepool', views.VirtualMachineResourcePoolViewSet)
router.register('physicalserverresourcepool', views.PhysicalServerResourcePoolViewSet)

urlpatterns = router.urls
