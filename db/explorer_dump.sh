#!/bin/bash
db-to-sqlite "postgresql://$DATABASE_USER:$DATABASE_PASSWORD@$DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME" /data/explore/busterexplore.db \
   --all \
   --skip=ar_internal_metadata \
   --skip=draft_rankings \
   --skip=draft_ranking_values \
   --skip=draft_stat_preferences \
   --skip=draft_wanteds \
   --skip=schema_migrations \
   --skip=owners \
   --skip=uploads \
   --skip=stat_sheets \
   --skip=svg_images \
   --progress
