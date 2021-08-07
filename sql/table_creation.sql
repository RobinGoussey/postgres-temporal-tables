CREATE EXTENSION IF NOT EXISTS psql_temporal;

CREATE TABLE firemen_temporal (
	id serial PRIMARY KEY,
	name text,
	"rank" text
);
-- fill table
INSERT INTO firemen_temporal (name,"rank") VALUES ('Bram','Sgt.');
-- create tables
select public.convert_to_temporal('firemen_temporal');

-- check that history table is created exist
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE  table_schema = 'temporal_firemen_temporal_history'
   AND    table_name   = 'table_name'
   );

-- make sure the previous history is transferred.
select count(id) from temporal_firemen_temporal_history;