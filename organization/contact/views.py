from rest_framework import filters
from rest_framework import permissions
from rest_framework import viewsets
from organization.contact import models
from organization.contact import serializers


class PeopleViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = models.People.objects.all()
    serializer_class = serializers.PeopleSeriliazer

    # Applies Filters
    filter_backends = (filters.DjangoFilterBackend, filters.SearchFilter)
    filter_fields = ('name', 'email', 'mobile', 'chinese_name')
    search_fields = ('name', 'chinese_name')

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(PeopleViewSet, self).perform_create(serializer)
