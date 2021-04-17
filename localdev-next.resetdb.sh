#!/bin/bash
docker-compose --file localdev-next.docker-compose.yml down
docker volume rm busterleague-next_next_data
docker volume rm busterleague-next_next_redis
docker-compose --file localdev-next.docker-compose.yml up -d
docker-compose --file localdev-next.docker-compose.yml logs -f busterleaguedb-next