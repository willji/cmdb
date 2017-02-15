from django.db.models.query_utils import Q
from rest_framework import serializers
from abstract.serializers import CommonHyperlinkedModelSerializer
from organization.contact.models import People
from organization.department.models import Department
from organization.environment.models import Environment, Location
from components.network.models import Ipv4Address
from components.device.models import LBGroup
from components.application import models


class ApplicationGroupRelatedField(serializers.RelatedField):

    '''
    A customized related field for handling application group.
    '''

    def get_queryset(self):
        queryset = models.ApplicationGroup.objects.select_related('application', 'environment', 'location', 'creator', 'last_modified_by')\
                                                  .select_related('application__department', 'application__type', 'application__level')\
                                                  .select_related('application__owner', 'application__backup_owner', 'application__backup2_owner')\
                                                  .select_related('application__ops_owner')\
                                                  .prefetch_related('ipaddresses', 'lbgroup')\
                                                  .all()
                                                                            
        return queryset

    def to_representation(self, value):
        serializer = ApplicationGroupSerializer(value, context=self.context)
        return serializer.data['display_name']

    def to_internal_value(self, data):
        try:
            appGroupNames = data.split('_')
            appName = appGroupNames[0]
            envName = appGroupNames[1]
            locationPk = appGroupNames[2]
            appGroup = self.queryset.get(Q(application__name=appName) & Q(environment__name=envName) & Q(location__pk=locationPk))
            return appGroup
        except Exception as e :
            raise serializers.ValidationError(e.message)

class ApplicationGroupSerializer(CommonHyperlinkedModelSerializer):

    application = serializers.SlugRelatedField(queryset=models.Application.objects.all(), slug_field='name')
    environment = serializers.SlugRelatedField(queryset=Environment.objects.all(), slug_field='name')
    location = serializers.SlugRelatedField(queryset=Location.objects.all(), slug_field='name')
    ipaddresses = serializers.SlugRelatedField(many=True, queryset=Ipv4Address.objects.all(), slug_field='name')
    lbgroup = serializers.SlugRelatedField(many=True, queryset=LBGroup.objects.all(), slug_field='name', required=False)

    # Using SerializerMethodField to get owner, department and type from application.
    # REF: http://www.django-rest-framework.org/api-guide/fields/#serializermethodfield
    owner = serializers.SerializerMethodField()
    backup_owner = serializers.SerializerMethodField()
    backup2_owner = serializers.SerializerMethodField()
    ops_owner = serializers.SerializerMethodField()
    department = serializers.SerializerMethodField()
    type = serializers.SerializerMethodField()
    display_name = serializers.SerializerMethodField()
    port = serializers.SerializerMethodField()
    level = serializers.SerializerMethodField()

    class Meta:
        model = models.ApplicationGroup

    def get_owner(self, obj):
        if obj.application.owner:
            return obj.application.owner.chinese_name

    def get_backup_owner(self, obj):
        if obj.application.backup_owner:
            return obj.application.backup_owner.chinese_name

    def get_backup2_owner(self, obj):
        if obj.application.backup2_owner:
            return obj.application.backup2_owner.chinese_name

    def get_ops_owner(self, obj):
        if obj.application.ops_owner:
            return obj.application.ops_owner.chinese_name

    def get_department(self, obj):
        return obj.application.department.name

    def get_type(self, obj):
        return obj.application.type

    def get_port(self, obj):
        return obj.application.port

    def get_level(self, obj):
        return obj.application.level

    def get_display_name(self, obj):
        return '{0}_{1}_{2}'.format(obj.application.name, obj.environment.name, obj.location.pk)


class ApplicationSerializer(CommonHyperlinkedModelSerializer):

    owner = serializers.SlugRelatedField(queryset=People.objects.all(), slug_field='chinese_name', allow_null=True)
    backup_owner = serializers.SlugRelatedField(queryset=People.objects.all(), slug_field='chinese_name', allow_null=True)
    backup2_owner = serializers.SlugRelatedField(queryset=People.objects.all(), slug_field='chinese_name', allow_null=True)
    ops_owner = serializers.SlugRelatedField(queryset=People.objects.all(), slug_field='chinese_name', allow_null=True)
    department = serializers.SlugRelatedField(queryset=Department.objects.all(), slug_field='name')

    # Using SerializerMethodField to get application groups.
    # REF: http://www.django-rest-framework.org/api-guide/fields/#serializermethodfield
    app_groups = serializers.SerializerMethodField()
    warmup_urls = serializers.SerializerMethodField()

    class Meta:
        model = models.Application

    def get_app_groups(self, obj):
        # REF:
        # https://docs.djangoproject.com/en/1.9/ref/models/relations/#related-objects-reference
        # http://stackoverflow.com/questions/23353474/foreignrelatedobjectsdescriptor-object-has-no-attribute-all

        results = dict()
        for appgroup in obj.applicationgroup_set.all():
            ipList = []
            name = '{0}_{1}'.format(appgroup.environment.name, appgroup.location.pk)
            for ip in appgroup.ipaddresses.all():
                ipList.append(ip.name)
            results[name] = ipList
        return results

    def get_warmup_urls(self, obj):
        result = []
        for i in obj.applicationwarmupurl_set.all():
            d = {}
            codes = []
            d['id'] = i.pk
            d['sequence_number'] = i.sequence_number
            d['warmup_url'] = i.warmup_url.name
            d['expected_text'] = i.expected_text
            for j in i.expected_codes.all():
                codes.append(j.name)
            d['expected_codes'] = codes
            result.append(d)
        return result

class ApplicationHistorySerializer(CommonHyperlinkedModelSerializer):

    application_group = ApplicationGroupRelatedField(queryset=models.ApplicationGroup.objects.all())

    # add current_version per FrontEnd engineer's request
    current_version = serializers.SerializerMethodField()

    class Meta:
        model = models.ApplicationHistory

    def get_current_version(self, obj):
        return obj.application_group.version

class WarmupUrlSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.WarmupUrl

class StatusCodeSerializer(CommonHyperlinkedModelSerializer):

    class Meta:
        model = models.StatusCode

class ApplicationWarmupUrlSerializer(CommonHyperlinkedModelSerializer):
    
    application = serializers.SlugRelatedField(queryset=models.Application.objects.all(), slug_field='name')
    warmup_url = serializers.SlugRelatedField(queryset=models.WarmupUrl.objects.all(), slug_field='name')
    expected_codes = serializers.SlugRelatedField(many=True, queryset=models.StatusCode.objects.all(), slug_field='name')

    class Meta:
        model = models.ApplicationWarmupUrl

