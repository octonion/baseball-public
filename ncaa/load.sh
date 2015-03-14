#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'baseball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql template1 -t -c \"create database baseball\" > /dev/null 2>&1"
   eval $cmd
fi

psql baseball -f schema/create_schema_ncaa.sql

tail -q -n+2 csv/ncaa_games_mt_*.csv >> /tmp/games.csv
psql baseball -f loaders/load_ncaa_games.sql
rm /tmp/games.csv

tail -q -n+2 csv/ncaa_player_statistics_mt_*.csv >> /tmp/ncaa_player_statistics.csv
rpl ".|" "|" /tmp/ncaa_player_statistics.csv
rpl ".0|" "|" /tmp/ncaa_player_statistics.csv
rpl ".00|" "|" /tmp/ncaa_player_statistics.csv
rpl ".000|" "|" /tmp/ncaa_player_statistics.csv
psql baseball -f loaders/load_ncaa_player_statistics.sql
rm /tmp/ncaa_player_statistics.csv

cp csv/ncaa_schools.csv /tmp/ncaa_schools.csv
psql baseball -f loaders/load_ncaa_schools.sql
rm /tmp/ncaa_schools.csv

cp csv/ncaa_divisions.csv /tmp/ncaa_divisions.csv
psql baseball -f loaders/load_ncaa_divisions.sql
rm /tmp/ncaa_divisions.csv
