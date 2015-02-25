#!/bin/sh

#unset CDPATH

psql baseball -f schema/create_naia.sql

tail -q -n+2 csv/naia_team_games*.csv >> /tmp/games.csv
rpl -q -e '\r\n' '' /tmp/games.csv
psql baseball -f loaders/load_naia_games.sql
rm -f /tmp/games.csv

psql baseball -f loaders/load_naia_teams.sql
