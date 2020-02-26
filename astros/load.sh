#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'astros';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb astros;"
   eval $cmd
fi

psql astros -f schema/create_schema.sql

cp csv/kershaw.csv /tmp/kershaw.csv
psql astros -f loaders/load_kershaw.sql
rm /tmp/kershaw.csv
