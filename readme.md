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