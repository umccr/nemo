.EXPORT_ALL_VARIABLES:
DB_HOSTNAME ?= localhost
DB_PORT ?= 5432

.PHONY: test suite

install:
	@uv sync

hello:
	@uv run ./nemo/hello.py

check: lint

lint:
	@uv run ruff check

format:
	@uv run ruff format

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
