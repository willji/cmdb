# encoding: utf8

from abstract.serializers import CommonHyperlinkedModelSerializer
from organization.environment import models


class EnvironmentSeriliazer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.Environment

class LocationSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.Location