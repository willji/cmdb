# encoding: utf8

from django.contrib import admin
from components.application import models

class ApplicationHistoryAdmin(admin.ModelAdmin):
    list_display = ('task_id', 'creator', 'last_modified_by', 'created_date', 'modified_date', 'application_group', 'version')
    fields = ('application_group', 'version', 'task_id')
    search_fields = ('version', 'task_id')

admin.site.register(models.WarmupUrl)
admin.site.register(models.StatusCode)
admin.site.register(models.ApplicationWarmupUrl)
admin.site.register(models.ApplicationGroup)
admin.site.register(models.ApplicationHistory, ApplicationHistoryAdmin)
admin.site.register(models.Application)
