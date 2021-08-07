#!/bin/bash
docker-compose exec postgres bash -c "cd /usr/share/postgresql/12/extension/psql_temporal && make clean && make && make install && make installcheck"