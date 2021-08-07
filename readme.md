# Postgres temporal tables.
This is an inital try to a poor man's temporal table. 

It will add triggers that when updating a temporal table, will fill it into the history.
So let's say you have a table employee, then it will create an underlying temporal_employee_history table, and an function employee_as_of(timestamptz).

Currently it only supports System time temporality. But I'm planning on adding the Application temporality, as far as a database can do that.

possible Additions: 
-- allow renaming of application fields (currently is ApplicationStartTime and ApplicationEndTime).
-- allow limiting temporal update on certain fields (eg. only on rank or name, and not on the post field).
-- Application temporal table + a view for the current time.
-- Add argument to the as_of function to choose SYSTEM or APPLICATION time.

## Example

```SQL
CREATE EXTENSION IF NOT EXISTS psql_temporal;

CREATE TABLE firemen (
	id serial PRIMARY KEY,
	name text,
	"rank" text
);
-- fill table
INSERT INTO update_to_history_firemen_temporal (name,"rank") VALUES ('Bram','Sgt.');
-- Conver to temporal.
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
```


## Setup
Run the docker-containers:
```bash
docker-compose up -d$
# Build
make clean && make && make install
# test
./test.sh
```

## Possibly needed:
Docker(-compose)
And
```bash
sudo apt-get install postgresql-server-dev-12
```

