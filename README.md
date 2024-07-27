# Postgres with Superstore database

## Run

Go to `dc-pg-superstore` and run command.
  
```shell
docker container run --rm -d --name pg16-superstor \
    -e POSTGRES_USER=pguser1 \
    -e POSTGRES_PASSWORD=pgpass123 \
    -e POSTGRES_DB=superstore_db \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -p 5432:5432 \
    -v "$(pwd)"/pg-init.d:/docker-entrypoint-initdb.d \
    -v "$(pwd)"/data:/var/lib/postgresql/data \
    -v "$(pwd)"/csv:/csv \
    postgres:16
```

Tree:

```shell
dc-pg-superstore
├── csv
│   ├── Sample - Superstore Sales - Orders.csv
│   ├── Sample - Superstore Sales - Returns.csv
│   └── Sample - Superstore Sales - Users.csv
├── data
│   └── emptyfile
└── pg-init.d
    ├── 00_create_t.sql
    ├── 01_import_csv.sql
    └── 02_norm.sql
```


## Explain

#### 1

At first start with docker mount three volumes. Then postgres does database initialization, create `pgdata` in `"$(pwd)"/data` and stop. There is `--rm` flag, so container will autodelete after every stop and first run looks like nothing happened at all. 

If you don't like `--rm` - don't use. I use it for autorelease unnamed volumes to save space on disk.

Second run the same docker command - container doesn't stop after starting. As `pgdata` already exists there is no need to repeat database initialization.

If you need to create database as new - just drop all in `./data` directory

```shell
$ pwd 
/some-path/dc-pg-superstore

$ rm -rf data/* 
```

and run docker command again.

#### 2

├── 00_create_t.sql

Creates schema and tables.

├── 01_import_csv.sql

Import flat data.

└── 02_norm.sql

Creating star model and migrating data from raw schema. If you don't need star model, just rename last file.

## Why no image?

Dockerfile or new image in dockerhub doesn't exempt you from mounting your volumes, so that's faster for me use it in a way of `git clone` + `docker run ...` and sometimes drop `pgdata`.

# Links

https://hub.docker.com/_/postgres/

https://github.com/docker-library/docs/blob/master/postgres/README.md