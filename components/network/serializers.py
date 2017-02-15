# encoding: utf8

from django.db.models import Count
from rest_framework import serializers
from netaddr import *
from abstract.serializers import CommonHyperlinkedModelSerializer
from components.network.models import Ipv4Address, Ipv4Network

class IPv4AddressSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = Ipv4Address

class IPv4NetworkSerializer(CommonHyperlinkedModelSerializer): 

    used = serializers.SerializerMethodField()
    used_ips = serializers.SerializerMethodField()
    free = serializers.SerializerMethodField()
    free_vm_ip_count = serializers.SerializerMethodField()

    class Meta:
        model = Ipv4Network

    def get_used(self, obj):
        # get network addresses based on the network 10.10.101.0/24
        network = IPNetwork(obj.name)
        addresses = [x for x in list(network)]

        # Following code can get m2m fields, In this case, it should be applicationgroup and device.
        # m2m_fields = [x.name for x in Ipv4Address._meta.get_fields() if x.many_to_many]

        # REF:
        # https://docs.djangoproject.com/en/1.8/topics/db/aggregation/

        ips = Ipv4Address.objects.filter(name__in=addresses)\
                                 .annotate(Count('device'), Count('applicationgroup'))\
                                 .all()

        # using map function to figure out used ip addresses, for example:
        # device_ips = [1, 0, 1, 0]
        # appgrp_ips = [1, 1, 2, 0]
        # result = [1, 1, 1, 0]
        # note: one ip may be used by multiple devices or application groups, please pay attention to the function in map.
        device_ips = [ip.device__count for ip in ips]
        appgrp_ips = [ip.applicationgroup__count for ip in ips]
        result = map(lambda x, y: 1 if x + y > 0 else 0, device_ips, appgrp_ips)        

        # calculate number of free ip address, used ip address
        allocated = sum(result)
        self.used_ips = [str(ips[index]) for index, value in enumerate(result) if value == 1]
        self.free = network.size - allocated - 2
        if obj.name.split('/')[0][:-2] in ['10.10.101', '10.11.101', '10.12.99', '10.12.100', '10.12.101']:
            self.free_vm_ip_count = len([str(ips[index]) for index, value in enumerate(result) if value == 0 and int(str(ips[index]).split('.')[-1]) in range(11, 251)])
        else:
            self.free_vm_ip_count = len([str(ips[index]) for index, value in enumerate(result) if value == 0 and int(str(ips[index]).split('.')[-1]) in range(11, 101)])

        return allocated

    def get_free(self, obj):
        return self.free

    def get_used_ips(self, obj):
        return self.used_ips

    def get_free_vm_ip_count(self, obj):
        return self.free_vm_ip_count

    # Overrides default create method to automatically populate address pool.
    # Using bulk_create with batch_size to avoid exception, 'MySQL server has gone away'.
    # See https://docs.djangoproject.com/en/1.8/ref/models/querysets/, bulk_create
    def create(self, validated_data):
        prefix = validated_data['name']
        nwk = IPNetwork(prefix)        
        rawAddrs = [Ipv4Address(name=str(x), creator=validated_data['creator'], \
                    last_modified_by=validated_data['last_modified_by']) for x in list(nwk)]
        addresses = Ipv4Address.objects.bulk_create(rawAddrs, batch_size=30)
        return super(IPv4NetworkSerializer, self).create(validated_data)

    def validate(self, attrs):
        if attrs['name'].find('/') == -1:
            raise serializers.ValidationError('Network mask is missing!')

        return super(IPv4NetworkSerializer, self).validate(attrs)
