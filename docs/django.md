Django
======

- App: web app that does something e.g. blog, db etc. An app can be reused in multiple projects.
- Project: collection of apps that make up a website. A project can have multiple apps.


| Description                                                     | Command                                                     |
| ----------------                                                | ----------------------------------------------------------- |
| Install                                                         | `conda create -n djangoenv django -c conda-forge`           |
| Create project                                                  | `django-admin startproject proj1`                           |
| Create app                                                      | `python manage.py startapp posts`                           |
| Run server                                                      | `python manage.py runserver` / `uv run manage.py runserver` |
| Create migration                                                | `python manage.py makemigrations`                           |
| Create new foo migration under `foo/migrations/0001_initial.py` | `python manage.py makemigrations foo`                       |
| Print SQL migrate                                               | `python manage.py sqlmigrate foo 0001`                      |
| Apply migration                                                 | `python manage.py migrate`                                  |
| Open shell                                                      | `python manage.py shell`                                    |

- Database:
  - make sure user has login attribute:
    - `createuser orcabus`
    - `CREATE ROLE orcabus LOGIN;`
    - `CREATE USER orcabus` # same as above
- Migrate:
  - `python manage.py migrate`
  - looks at the `INSTALLED_APPS` setting and creates necessary db tables.
  - synchronises the db state with the current set of models and migrations.
