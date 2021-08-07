# Tryout
for first version, followed: http://big-elephants.com/2015-10/writing-postgres-extensions-part-i/

## Setup
Run the docker-containers:
```bash
docker-compose up -d$
# Build
make clean && make && make install
# test
./test.sh
```

Possibly needed:
```bash
sudo apt-get install postgresql-server-dev-12
```

possible extensions: 
-- allow renaming of application fields
-- allow limiting temporal update on certain fields (eg. only on rank or name, and not on the post field).