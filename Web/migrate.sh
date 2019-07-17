#!/bin/bash
python manage.py makemigrations polls
python manage.py sqlmigrate polls 0001
python manage.py migrate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell
exec "$@"
