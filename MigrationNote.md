����MakeMigrations

��һ��makemigrations��Ҫ��ע�� VirtualMachine �µ�
applications = models.ManyToManyField('application.Application', blank=True, help_text='Applications that are deployed in one VM')

���֮��ȡ������ע�ͣ��ٴ�ִ��makemigrations������ᷢ��django.db.migrations.graph.CircularDependencyError��

�ο���
http://stackoverflow.com/questions/29003672/django-django-db-migrations-graph-circulardependencyerror