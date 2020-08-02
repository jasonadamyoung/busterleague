#!/bin/bash
echo "Downloading data from $DB_SHELL_SERVER... (this is going to take a while)"
ssh $DB_SHELL_ACCOUNT@$DB_SHELL_SERVER "pg_dump --user=$POSTGRES_DUMP_ACCOUNT --dbname=$POSTGRES_DUMP_LEAGUE_DATABASE | gzip -9" > ./localdev.volumes/db_dump/$POSTGRES_DUMP_LEAGUE_DATABASE.sql.gz
gunzip --force --verbose ./localdev.volumes/db_dump/$POSTGRES_DUMP_LEAGUE_DATABASE.sql.gz
