CREATE EXTENSION IF NOT EXISTS psql_temporal;

CREATE TABLE test_as_of_temporal (
	id serial PRIMARY KEY,
	name text,
	"rank" text
);
-- fill table
INSERT INTO test_as_of_temporal (name,"rank") VALUES ('Bram','Sgt.');
-- create tables
select public.convert_to_temporal('test_as_of_temporal');



-- We should get the current state (1 record)
select id, name, rank from test_as_of_temporal_as_of(now());

-- This is a way to save the time, I couldn't get variables to work.
CREATE TEMP TABLE temp_time(time timestamptz);
insert into temp_time (time) values (now());

-- trigger update to update the history table
UPDATE test_as_of_temporal SET "rank" = 'Cpt.';

-- We should get the previous record state (1 record)
select id, name, rank from test_as_of_temporal_as_of((select * from temp_time));

-- We should get the current state (1 record)
select id, name, rank from test_as_of_temporal_as_of(now());



