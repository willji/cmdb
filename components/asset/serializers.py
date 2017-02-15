# encoding: utf8

from rest_framework import serializers
from abstract.serializers import CommonHyperlinkedModelSerializer
from organization.contact.models import People
from organization.department.models import Department
from components.asset.models import AssetStatus, AssetType, Asset, AssetSpecification


class AssetStatusSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = AssetStatus

class AssetTypeSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = AssetType

class AssetSpecificationSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = AssetSpecification

class AssetSpecificationSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = AssetSpecification

class AssetSerializer(CommonHyperlinkedModelSerializer):

    status = serializers.SlugRelatedField(queryset=AssetStatus.objects.all(), slug_field='name')
    type = serializers.SlugRelatedField(queryset=AssetType.objects.all(), slug_field='name')
    dc_contact = serializers.SlugRelatedField(queryset=People.objects.all(), many=True, slug_field='name', allow_null=True)
    vendor_contact = serializers.SlugRelatedField(queryset=People.objects.all(), many=True, slug_field='name', allow_null=True)
    owner = serializers.SlugRelatedField(queryset=People.objects.all(), slug_field='name', allow_null=True)
    department = serializers.SlugRelatedField(queryset=Department.objects.all(), slug_field='name', allow_null=True)
    specification = serializers.SlugRelatedField(queryset=AssetSpecification.objects.all(), slug_field='name', allow_null=True)

    class Meta:
        model = Asset