CREATE EXTENSION IF NOT EXISTS psql_temporal;

CREATE TABLE update_to_history_firemen_temporal (
	id serial PRIMARY KEY,
	name text,
	"rank" text
);
-- fill table
INSERT INTO update_to_history_firemen_temporal (name,"rank") VALUES ('Bram','Sgt.');
-- create tables
select public.convert_to_temporal('update_to_history_firemen_temporal');

-- test functionality of history
UPDATE update_to_history_firemen_temporal 
SET "rank" = 'Cpt.'
WHERE "rank" = 'Sgt.';

-- We can't use the timestamp columns, as they are constantly changing
select id , name , rank from temporal_update_to_history_firemen_temporal_history;

select id , name , rank from temporal_update_to_history_firemen_temporal_history where sysendtime is null;

-- Should be 2, since the start time should have been updated
select count(DISTINCT sysStartTime) from temporal_update_to_history_firemen_temporal_history;