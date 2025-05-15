#
# PgSQL - https://www.cybertec-postgresql.com/en/easy-guide-to-writing-postgresql-extensions/
#
PGFILEDESC = "Extension to convert a text to tile format"
EXTENSION = pg_make_title
DATA = pg_make_title--1.0.sql
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
