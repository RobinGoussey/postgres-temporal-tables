CREATE EXTENSION IF NOT EXISTS psql_temporal;

CREATE TABLE insert_firemen_temporal (
	id serial PRIMARY KEY,
	name text,
	"rank" text
);
-- fill table
INSERT INTO insert_firemen_temporal (name,"rank") VALUES ('Bram','Sgt.');
-- create tables
select public.convert_to_temporal('insert_firemen_temporal');

-- test functionality of history
INSERT INTO insert_firemen_temporal (name,"rank") VALUES ('Bert','Cp.');


-- We can't use the timestamp columns, as they are constantly changing
select id , name , rank from temporal_insert_firemen_temporal_history where sysendtime is null and name = 'Bert';
