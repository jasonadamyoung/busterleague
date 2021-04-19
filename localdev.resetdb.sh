#!/bin/bash
docker compose --file localdev.docker-compose.yml down
docker volume rm busterleague_league_data
docker volume rm busterleague_league_redis
docker compose --file localdev.docker-compose.yml up -d
docker compose --file localdev.docker-compose.yml logs -f busterleaguedb