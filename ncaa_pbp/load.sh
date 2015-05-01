#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'baseball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
#   cmd="psql template1 -t -c \"create database baseball\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
   cmd="createdb baseball"
   eval $cmd
fi

psql baseball -f schema/create_schema.sql

cp csv/ncaa_teams.csv /tmp/teams.csv
psql baseball -f loaders/load_teams.sql
rm /tmp/teams.csv

tail -q -n+2 csv/ncaa_team_schedules_*.csv >> /tmp/schedules.csv
psql baseball -f loaders/load_schedules.sql
rm /tmp/schedules.csv

tail -q -n+2 csv/ncaa_team_rosters_*.csv >> /tmp/rosters.csv
rpl -e '\t--\t' '\t\t' /tmp/rosters.csv
rpl -e '\t-\t' '\t\t' /tmp/rosters.csv
psql baseball -f loaders/load_rosters.sql
rm /tmp/rosters.csv

#cp csv/ncaa_games_box_scores_mt.csv /tmp/ncaa_games_box_scores.csv
#psql baseball -f loaders/load_ncaa_games_box_scores.sql
#rm /tmp/ncaa_games_box_scores.csv

#cp csv/ncaa_team_summaries.csv /tmp/ncaa_team_summaries.csv
#rpl -e '\t-\t' '\t\t' /tmp/ncaa_team_summaries.csv
#rpl -e '\t-\t' '\t\t' /tmp/ncaa_team_summaries.csv
#rpl -q ',' '' /tmp/ncaa_team_summaries.csv
#rpl -q '""' '' /tmp/ncaa_team_summaries.csv
#rpl -q ' ' '' /tmp/ncaa_team_summaries.csv
#psql baseball -f loaders/load_ncaa_team_summaries.sql
#rm /tmp/ncaa_team_summaries.csv

#cp csv/ncaa_player_summaries.csv /tmp/ncaa_player_summaries.csv
#rpl -e '\t-\t' '\t\t' /tmp/ncaa_player_summaries.csv
#rpl -e '\t-\t' '\t\t' /tmp/ncaa_player_summaries.csv
#rpl -q '""' '' /tmp/ncaa_player_summaries.csv
#rpl -q ' ' '' /tmp/ncaa_player_summaries.csv
#psql baseball -f loaders/load_ncaa_player_summaries.sql
#rm /tmp/ncaa_player_summaries.csv

tail -q -n+2 csv/ncaa_games_periods_*.csv >> /tmp/periods.csv
rpl "[" "{" /tmp/periods.csv
rpl "]" "}" /tmp/periods.csv
psql baseball -f loaders/load_periods.sql
rm /tmp/periods.csv

cp csv/ncaa_games_play_by_play_*.csv.gz /tmp
gzip -d /tmp/ncaa_games_play_by_play_*.csv.gz
tail -q -n+2 /tmp/ncaa_games_play_by_play_*.csv >> /tmp/play_by_play.csv
psql baseball -f loaders/load_play_by_play.sql
rm /tmp/play_by_play.csv
rm /tmp/ncaa_games_play_by_play_*.csv

