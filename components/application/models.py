# encoding: utf8

from django.db import models
from textwrap import wrap
from abstract.models import CommonModel, UniqueNameDescModel
from organization.contact.models import People
from organization.department.models import Department
from organization.environment.models import Environment, Location
from components.network.models import Ipv4Address



class Application(UniqueNameDescModel):

    alias = models.CharField(max_length=80, blank=True, null=True, help_text='Alias of one application.')
    department = models.ForeignKey(Department)
    type = models.CharField(max_length=20, blank=True, null=True, help_text='Type of one application, like IIS, service, NodeJS')
    owner = models.ForeignKey(People, help_text='Owner of one application.', blank=True, null=True, related_name='owner')
    backup_owner = models.ForeignKey(People, help_text='Back owner of one application.', blank=True, null=True, related_name='backup_owner')
    backup2_owner = models.ForeignKey(People, help_text='Back owner of one application.', blank=True, null=True, related_name='backup2_owner')
    ops_owner = models.ForeignKey(People, help_text='Ops owner of one application.', blank=True, null=True, related_name='ops_owner')
    site_id = models.PositiveSmallIntegerField(help_text='Site id of one application', blank=True, null=True)
    port = models.PositiveIntegerField(help_text='port of one application', blank=True, null=True)
    level = models.IntegerField(help_text='level of one application', blank=True, null=True)

    def __unicode__(self):
        return self.name

    class Meta:
        ordering = ['name', ]

class ApplicationGroup(CommonModel):
    application = models.ForeignKey(Application)
    environment = models.ForeignKey(Environment)
    location = models.ForeignKey(Location)
    ipaddresses = models.ManyToManyField(Ipv4Address)
    version = models.CharField(max_length=20, blank=True, null=True, help_text='Version of one application group, can be used for A/B test scenario.')
    last_version = models.CharField(max_length=20, blank=True, null=True, help_text='Last version of one application group, can be used for A/B test scenario.')

    # Use model name here, because device module is imported after application.
    # REF: https://docs.djangoproject.com/en/1.9/ref/models/fields/#foreignkey
    lbgroup = models.ManyToManyField('device.LBGroup', blank=True)

    class Meta:
        unique_together = ('application', 'environment', 'location')
        ordering = ['application', ]

    def __unicode__(self):
        return "{0}_{1}_{2}".format(self.application.name, self.environment.name, self.location.pk)

class ApplicationHistory(CommonModel):
    application_group = models.ForeignKey(ApplicationGroup, default=None)
    version = models.CharField(max_length=20, blank=True, null=True, help_text='Version of one application')
    task_id = models.CharField(max_length=36, blank=True, null=True, help_text='Task id from release system.')

    class Meta:
        ordering = ['-created_date']

    def __unicode__(self):
        return str(self.application_group)


class StatusCode(CommonModel):
    name = models.CharField(max_length=80, unique=True)

    class Meta:
        ordering = ['name', ]

    def __unicode__(self):
        return self.name

class WarmupUrl(CommonModel):
    name = models.CharField(max_length=255, unique=True)

    class Meta:
        ordering = ['name', ]

    def __unicode__(self):
        name = self.name
        if len(name) > 40:
            name = "{0} ...".format(wrap(name, width=40)[0])
        return name

class ApplicationWarmupUrl(CommonModel):
    application = models.ForeignKey(Application)
    warmup_url = models.ForeignKey(WarmupUrl)
    expected_codes = models.ManyToManyField(StatusCode)
    expected_text = models.CharField(max_length=80, blank=True, null=True)
    sequence_number = models.CharField(max_length=80, blank=True, null=True)

    class Meat:
        unique_together = ('application', 'sequence_number')
        ordering = ['application', ]

    def __unicode__(self):
        return str(self.application)
