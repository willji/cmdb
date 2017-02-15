# encoding: utf8

from abstract.serializers import CommonHyperlinkedModelSerializer
from components.vmware import models


class VCenterServerSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.VCenterServer

class VMTemplateSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.VMTemplate