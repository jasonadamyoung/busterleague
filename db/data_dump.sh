#!/bin/bash
echo "$DATABASE_HOST:$DATABASE_PORT:$DATABASE_NAME:$DATABASE_USER:$DATABASE_PASSWORD" > ~/.pgpass
chmod 600 ~/.pgpass
pg_dump --user=$DATABASE_USER --dbname=$DATABASE_NAME --host=$DATABASE_HOST --port=$DATABASE_PORT | gzip -9 > ~/busterleague.sql.gz
