#!/bin/sh

# Pull Postgres image
docker pull postgres:15

# Remove any previously created containers if they exist
docker rm $(docker ps -aq --filter name=postgres-rf)

# Create and run a new Postgres container, seed initial data
docker run --name postgres-rf -p 5432:5432 -e POSTGRES_PASSWORD=test -e POSTGRES_DB=students -v $PWD/resources/sql/initdb:/docker-entrypoint-initdb.d -d postgres