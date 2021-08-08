CREATE EXTENSION IF NOT EXISTS psql_temporal;

CREATE TABLE update_firemen_temporal (
	id serial PRIMARY KEY,
	name text,
	"rank" text
);
-- fill table
INSERT INTO update_firemen_temporal (name,"rank") VALUES ('Bram','Sgt.');
-- create tables
select public.convert_to_temporal('update_firemen_temporal');

-- test functionality of history
UPDATE update_firemen_temporal 
SET "rank" = 'Cpt.'
WHERE "rank" = 'Sgt.';

-- We can't use the timestamp columns, as they are constantly changing
select id , name , rank from temporal_update_firemen_temporal_history;

select id , name , rank from temporal_update_firemen_temporal_history where sysendtime is null;

-- Should be 2, since the start time should have been updated
select count(DISTINCT sysStartTime) from temporal_update_firemen_temporal_history;

CREATE TABLE update_firemen_partial_temporal (
	id serial PRIMARY KEY,
	name text,
	"rank" text
);
INSERT INTO update_firemen_partial_temporal (name,"rank") VALUES ('Bram','Sgt.');

select public.convert_to_temporal('update_firemen_partial_temporal',update_columns=>'{rank}');

-- should be 1
select count(*) from temporal_update_firemen_partial_temporal_history;

UPDATE update_firemen_partial_temporal 
SET "name" = 'Bert';

-- should still be 1, since name should be ignored
select count(*) from temporal_update_firemen_partial_temporal_history;

UPDATE update_firemen_partial_temporal 
SET "rank" = 'Cpt.'
WHERE "rank" = 'Sgt.';

-- should be 2
select count(*) from temporal_update_firemen_partial_temporal_history;