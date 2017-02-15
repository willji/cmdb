
from django.conf.urls import patterns, url
from components.application import views
from rest_framework import routers


router = routers.DefaultRouter(trailing_slash=False)

router.register(r'warmupurl', views.WarmupUrlViewSet)
router.register(r'statuscode', views.StatusCodeViewSet)
router.register(r'applicationwarmupurl', views.ApplicationWarmupUrlViewSet)
router.register(r'application', views.ApplicationViewSet)
router.register(r'applicationgroup', views.ApplicationGroupViewSet)
router.register(r'applicationhistory', views.ApplicationHistoryViewSet)

urlpatterns = router.urls
