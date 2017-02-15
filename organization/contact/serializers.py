# encoding: utf8

from abstract import serializers
from organization.contact import models


class PeopleSeriliazer(serializers.CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.People