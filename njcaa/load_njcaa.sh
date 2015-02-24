#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'baseball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql template1 -t -c \"create database baseball\" > /dev/null 2>&1"
   eval $cmd
fi

psql baseball -f loaders/create_njcaa_schema.sql

cp csv/njcaa_schools_revised.csv /tmp/njcaa_schools.csv
cp csv/njcaa_schools_older.csv /tmp/njcaa_schools_older.csv
psql baseball -f loaders/load_njcaa_schools.sql
rm /tmp/njcaa_schools.csv
rm /tmp/njcaa_schools_older.csv

cp csv/njcaa_game_logs_mt.csv /tmp/njcaa_game_logs.csv
psql baseball -f loaders/load_njcaa_game_logs.sql
rm /tmp/njcaa_game_logs.csv
