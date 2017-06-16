#!/bin/bash

# Database

echo
echo "Creating database"
echo

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'baseball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb baseball"
   eval $cmd
fi

# Schema

echo
echo "Creating schema"
echo

psql baseball -f schema/bbref.sql

# Standard pitching

echo
echo "Standard pitching"
echo

cat csv/standard-pitching-*.csv >> /tmp/standard-pitching.csv
psql baseball -f loaders/standard-pitching.sql
rm /tmp/standard-pitching.csv

# Draft picks

echo
echo "Draft picks"
echo

cp csv/draft_picks.csv /tmp/draft_picks.csv
psql baseball -f loaders/draft_picks.sql
rm /tmp/draft_picks.csv
