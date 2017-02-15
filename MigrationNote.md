关于MakeMigrations

第一次makemigrations需要先注释 VirtualMachine 下的
applications = models.ManyToManyField('application.Application', blank=True, help_text='Applications that are deployed in one VM')

完成之后取消该行注释，再次执行makemigrations，否则会发生django.db.migrations.graph.CircularDependencyError。

参考：
http://stackoverflow.com/questions/29003672/django-django-db-migrations-graph-circulardependencyerror