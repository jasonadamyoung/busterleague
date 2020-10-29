#!/bin/bash
db-to-sqlite "postgresql://$DATABASE_USER:$DATABASE_PASSWORD@$DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME" /data/explore/busterexplore.db \
   --all \
   --skip=ar_internal_metadata \
   --skip=schema_migrations \
   --skip=owners \
   --skip=uploads \
   --skip=stat_sheets \
   --skip=svg_images \
   --progress
