CREATE EXTENSION IF NOT EXISTS psql_temporal;

CREATE TABLE delete_to_history_firemen_temporal (
	id serial PRIMARY KEY,
	name text,
	"rank" text
);
-- fill table
INSERT INTO delete_to_history_firemen_temporal (name,"rank") VALUES ('Bram','Sgt.');
-- create tables
select public.convert_to_temporal('delete_to_history_firemen_temporal');

-- should equal one: there is a current record in the history.
select count(id) from temporal_delete_to_history_firemen_temporal_history where sysendtime is null;

DELETE from delete_to_history_firemen_temporal where name = 'Bram';
-- should be 0, as now the last active record is closed.
select count(id) from temporal_delete_to_history_firemen_temporal_history where sysendtime is null;