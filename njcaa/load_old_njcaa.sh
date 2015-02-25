#!/bin/sh

tail -q -n+2 csv/teams.csv > /tmp/njcaa_teams.csv
psql baseball -f loaders/load_teams.sql
rm /tmp/njcaa_teams.csv

tail -q -n+2 csv/njcaa_games*.csv >> /tmp/njcaa_games.csv
rpl -q '@ ' '' /tmp/njcaa_games.csv
rpl -q '@' '' /tmp/njcaa_games.csv
rpl -q '""' '' /tmp/njcaa_games.csv
psql baseball -f loaders/load_njcaa.sql
rm /tmp/njcaa_games.csv
