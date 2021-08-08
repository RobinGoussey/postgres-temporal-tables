# Postgres temporal tables.
This is an inital try to a poor man's temporal table. 

It will add triggers that when updating a temporal table, will fill it into the history.
So let's say you have a table employee, then it will create an underlying temporal_employee_history table, and an function employee_as_of(timestamptz). Currently every update will trigger a history row.
Note it will also change the current table, to add time columns.

Currently it only supports System time temporality. But I'm planning on adding the Application temporality, as far as a database can do that.

possible Additions: 
- prevent recreating an already existing temporal table.
- allow renaming of application fields (currently is ApplicationStartTime and ApplicationEndTime).
- Application temporal table + a view for the current time.
- Add argument to the as_of function to choose SYSTEM or APPLICATION time.

## Example

See the expected folder for more examples with results.

```SQL
CREATE EXTENSION IF NOT EXISTS psql_temporal;

CREATE TABLE firemen (
	id serial PRIMARY KEY,
	name text,
	"rank" text
);
-- fill table
INSERT INTO firemen (name,"rank") VALUES ('Bram','Sgt.');
-- Convert to temporal. Only update when rank is changed.
select public.convert_to_temporal('firemen',update_columns => '{rank}');

-- test functionality of history
UPDATE firemen 
SET "rank" = 'Cpt.'
WHERE "rank" = 'Sgt.';

SELECT * from firemen;

SELECT firemen_as_of(<some_timestamp>);
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

