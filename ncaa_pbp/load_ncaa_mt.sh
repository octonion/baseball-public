#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'baseball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql template1 -t -c \"create database baseball\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
#   cmd="createdb baseball"
   eval $cmd
fi

psql baseball -f loaders/create_ncaa_pbp_schema.sql

cp csv/ncaa_teams.csv /tmp/ncaa_teams.csv
psql baseball -f loaders/load_ncaa_teams.sql
rm /tmp/ncaa_teams.csv

cp csv/ncaa_team_schedules_mt.csv /tmp/ncaa_team_schedules.csv
psql baseball -f loaders/load_ncaa_team_schedules.sql
rm /tmp/ncaa_team_schedules.csv

cp csv/ncaa_team_rosters_mt.csv /tmp/ncaa_team_rosters.csv
psql baseball -f loaders/load_ncaa_team_rosters.sql
rm /tmp/ncaa_team_rosters.csv

cp csv/ncaa_games_box_scores_mt.csv /tmp/ncaa_games_box_scores.csv
psql baseball -f loaders/load_ncaa_games_box_scores.sql
rm /tmp/ncaa_games_box_scores.csv

cp csv/ncaa_team_summaries.csv /tmp/ncaa_team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/ncaa_team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/ncaa_team_summaries.csv
rpl -q ',' '' /tmp/ncaa_team_summaries.csv
rpl -q '""' '' /tmp/ncaa_team_summaries.csv
rpl -q ' ' '' /tmp/ncaa_team_summaries.csv
psql baseball -f loaders/load_ncaa_team_summaries.sql
rm /tmp/ncaa_team_summaries.csv

cp csv/ncaa_player_summaries.csv /tmp/ncaa_player_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/ncaa_player_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/ncaa_player_summaries.csv
rpl -q '""' '' /tmp/ncaa_player_summaries.csv
rpl -q ' ' '' /tmp/ncaa_player_summaries.csv
psql baseball -f loaders/load_ncaa_player_summaries.sql
rm /tmp/ncaa_player_summaries.csv

cp csv/ncaa_games_periods_mt.csv /tmp/ncaa_games_periods.csv
rpl "[" "{" /tmp/ncaa_games_periods.csv
rpl "]" "}" /tmp/ncaa_games_periods.csv
psql baseball -f loaders/load_ncaa_games_periods.sql
rm /tmp/ncaa_games_periods.csv

cp csv/ncaa_games_play_by_play_mt.csv /tmp/ncaa_games_play_by_play.csv
psql baseball -f loaders/load_ncaa_games_play_by_play.sql
rm /tmp/ncaa_games_play_by_play.csv
