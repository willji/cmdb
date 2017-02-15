# encoding: utf8

from abstract.models import UniqueNameDescModel


class VCenterServer(UniqueNameDescModel):

    class Meta:
        ordering = ['name', ]    

class VMTemplate(UniqueNameDescModel):

    class Meta:
        ordering = ['name', ]