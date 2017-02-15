# encoding: utf8

from abstract import serializers
from organization.department import models


class DepartmentSeriliazer(serializers.CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.Department
