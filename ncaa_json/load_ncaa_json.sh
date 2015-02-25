#!/bin/bash

cp games_2015.csv /tmp/games.csv
psql baseball -f load_ncaa_json.sql
rm /tmp/games.csv
