Django
======

- App: web app that does something e.g. blog, db etc. An app can be reused in multiple projects.
- Project: collection of apps that make up a website. A project can have multiple apps.


| Description      | Command                                                     |
| ---------------- | ----------------------------------------------------------- |
| Install          | `conda create -n djangoenv django -c conda-forge`           |
| Create project   | `django-admin startproject proj1`                           |
| Create app       | `python manage.py startapp posts`                           |
| Run server       | `python manage.py runserver` / `uv run manage.py runserver` |
