"""local dev Django settings

Usage:
- export DJANGO_SETTINGS_MODULE=nemo.settings.local
"""
import sys
from .base import *  # noqa

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'nemo',
        'USER': 'orcabus',
        'PASSWORD': 'orcabus',
        'HOST': os.getenv('DB_HOSTNAME', 'localhost'),
        'PORT': os.getenv('DB_PORT', 5432),
    }
}

ROOT_URLCONF = "nemo.urls.local"
RUNSERVER_PLUS_PRINT_SQL_TRUNCATE = sys.maxsize
