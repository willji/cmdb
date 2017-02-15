# encoding: utf8

from abstract import models as mymodels
from django.db import models

class People(mymodels.PeopleModel):
    
    chinese_name = models.CharField(max_length=80, blank=True, null=True)

    class Meta:
        ordering = ['name',]
