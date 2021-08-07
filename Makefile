EXTENSION = psql_temporal
DATA = psql_temporal--0.0.1.sql
REGRESS = table_creation update_to_history insert_to_history     # our test script file (without extension)

# Postgres build stuff
# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)