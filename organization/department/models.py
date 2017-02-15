# encoding: utf8

from abstract import models


class Department(models.UniqueNameDescModel):

    class Meta:
        ordering = ['name',]
