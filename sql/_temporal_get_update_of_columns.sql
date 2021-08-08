CREATE EXTENSION IF NOT EXISTS psql_temporal;

--should return empty string
select _temporal_get_update_of_columns('{}');
--should return OF test, name
select _temporal_get_update_of_columns('{test,name}');

--should return OF name
select _temporal_get_update_of_columns('{name}');