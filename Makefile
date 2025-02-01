.EXPORT_ALL_VARIABLES:
DJANGO_SETTINGS_MODULE = nemo.settings.local
DB_HOSTNAME ?= localhost
DB_PORT ?= 5432

.PHONY: test suite

install:
	@uv sync

hello:
	@uv run ./nemo/hello.py

serve:
	@uv run ./manage.py runserver

check: lint

lint:
	@uv run ruff check

format:
	@uv run ruff format

## full mock suite test pipeline - install deps, bring up compose stack, run suite, bring down compose stack
#test: install up suite down
#
#suite:
#	@python manage.py test
#
#migrate:
#	@python manage.py migrate
#
#start: migrate
#	@python manage.py runserver_plus 0.0.0.0:8000
#
#mock:
#	@python manage.py generate_analysis_for_metadata
#
#run-mock: reset-db migrate mock start
#
#openapi:
#	@python manage.py generateschema > orcabus.hlo.openapi.yaml
#
#validate: openapi
#	@python -m openapi_spec_validator orcabus.hlo.openapi.yaml
#
#coverage: install up migrate
#	@echo $$DJANGO_SETTINGS_MODULE
#	@coverage run --source='.' manage.py test
#
#report:
#	@coverage report -m
#	@coverage html
#
#up:
#	@docker compose up --wait -d
#
#down:
#	@docker compose down
#
#stop: down
#
#ps:
#	@docker compose ps
#
#psql:
#	@docker exec -e PGPASSWORD=orcabus -it orcabus_db psql -h 0.0.0.0 -d workflow_manager -U orcabus
#
## database operation
#reset-db:
#	@docker exec -e PGPASSWORD=orcabus -it orcabus_db psql -h $(DB_HOSTNAME) -U orcabus -d orcabus -c "DROP DATABASE IF EXISTS workflow_manager;"
#	@docker exec -e PGPASSWORD=orcabus -it orcabus_db psql -h $(DB_HOSTNAME) -U orcabus -d orcabus -c "CREATE DATABASE workflow_manager;"
#
#s3-dump-download:
#	@aws s3 cp s3://orcabus-test-data-843407916570-ap-southeast-2/workflow-manager/wfm_dump.sql.gz data/wfm_dump.sql.gz
#
#db-load-data: reset-db
#	@gunzip -c data/wfm_dump.sql.gz | docker exec -i orcabus_db psql -U orcabus -d workflow_manager >/dev/null
#
#s3-dump-download-if-not-exists:
#		@if [ -f "data/wfm_dump.sql.gz" ]; then \
#			echo "Using existing sql dump from './data/wfm_dump.sql.gz"; \
#		else \
#			echo "Downloading sql dump from './data/wfm_dump.sql.gz"; \
#			$(MAKE) s3-dump-download; \
#		fi
#
#s3-load: s3-dump-download-if-not-exists db-load-data
