# encoding: utf8

from abstract.models import UniqueNameDescModel


class Environment(UniqueNameDescModel):

    class Meta:
        ordering = ['name',]

class Location(UniqueNameDescModel):

    class Meta:
        ordering = ['name',]