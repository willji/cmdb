from rest_framework import filters
from rest_framework import permissions
from rest_framework import viewsets
from organization.department import models
from organization.department import serializers


class DepartmentViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = models.Department.objects.all()
    serializer_class = serializers.DepartmentSeriliazer

    # Applies Filters
    filter_backends = (filters.DjangoFilterBackend,)
    filter_fields = ('name',)

    # Applies permissions
    permission_classes = (permissions.DjangoModelPermissions,)

    def perform_create(self, serializer):
        serializer.save(
            creator = self.request.user,
            last_modified_by = self.request.user
        )
        return super(DepartmentViewSet, self).perform_create(serializer)
