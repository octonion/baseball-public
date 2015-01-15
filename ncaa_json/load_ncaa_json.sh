#!/bin/bash

cp games_2014.csv /tmp/games_2014.csv
psql baseball -f load_ncaa_json.sql
rm /tmp/games_2014.csv
