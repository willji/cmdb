"""
Definition of urls for cmdb.
"""

from rest_framework.authtoken import views
from django.conf.urls import patterns, include, url

# Enable Admin site auto discovery
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Swagger UI
    url(r'^api/cmdb/', include('rest_framework_swagger.urls')),

    # Rest API authentication
    url(r'^api/cmdb/api-auth/', include('rest_framework.urls', namespace='rest_framework')),
    
    # components urls
    url(r'^api/cmdb/applications/', include('components.application.urls')),
    url(r'^api/cmdb/assets/', include('components.asset.urls')),
    url(r'^api/cmdb/devices/', include('components.device.urls')),
    url(r'^api/cmdb/networks/', include('components.network.urls')),
    url(r'^api/cmdb/resourcepools/', include('components.respool.urls')),
    url(r'^api/cmdb/vmware/', include('components.vmware.urls')),

    # organization urls
    url(r'^api/cmdb/contacts/', include('organization.contact.urls')),
    url(r'^api/cmdb/departments/', include('organization.department.urls')),
    url(r'^api/cmdb/environments/', include('organization.environment.urls')),

    # Admin Site
    url(r'^api/cmdb/admin/', include(admin.site.urls)),

    # Token Infra
    url(r'^api/cmdb/token/', views.obtain_auth_token),
)
