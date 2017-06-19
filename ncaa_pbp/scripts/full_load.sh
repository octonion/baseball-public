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

psql baseball -f schema/create_schema.sql

# Years with data

echo
echo "Years with data"
echo

cp csv/ncaa_years.csv /tmp/years.csv
psql baseball -f loaders/load_years.sql
rm /tmp/years.csv

# Divisions by year with data

echo
echo "Divisions by year with data"
echo

cp csv/ncaa_years_divisions.csv /tmp/years_divisions.csv
psql baseball -f loaders/load_years_divisions.sql
rm /tmp/years_divisions.csv

# Teams

echo
echo "Teams"
echo

tail -q -n+2 csv/ncaa_teams_2*.csv >> /tmp/teams.csv
psql baseball -f loaders/load_teams.sql
rm /tmp/teams.csv

# Team schedules

echo
echo "Team schedules"
echo

tail -q -n+2 csv/ncaa_team_schedules_*.csv >> /tmp/schedules.csv
psql baseball -f loaders/load_schedules.sql
rm /tmp/schedules.csv

# Rosters

echo
echo "Rosters"
echo

tail -q -n+2 csv/ncaa_team_rosters_*.csv >> /tmp/rosters.csv
rpl -e '\t--\t' '\t\t' /tmp/rosters.csv
rpl -e '\t-\t' '\t\t' /tmp/rosters.csv
psql baseball -f loaders/load_rosters.sql
rm /tmp/rosters.csv

# Box scores - hitting 2016-2017
# Format changes on 4/27/2016!

echo
echo "Box scores - hitting 2016-2017"
echo

cp csv/ncaa_box_scores_hitting_201[67]_?.csv.gz /tmp
gzip -d /tmp/ncaa_box_scores_hitting_*.csv.gz

# Embedded tabs
rpl -e '\t,' ',' /tmp/ncaa_box_scores_hitting_2016_3.csv

tail -q -n+2 /tmp/ncaa_box_scores_hitting_201[7]_?.csv >> /tmp/box_scores.csv
tail -q -n+2 /tmp/ncaa_box_scores_hitting_201[6]_?.csv | awk -F'\t' 'NF==26{print}{}' >> /tmp/box_scores.csv

psql baseball -f loaders/load_box_scores_hitting.sql
rm /tmp/box_scores.csv
rm /tmp/ncaa_box_scores_hitting_*.csv

# Box scores - hitting 2014-2016

echo
echo "Box scores - hitting 2014-2016"
echo

cp csv/ncaa_box_scores_hitting_201[456]_?.csv.gz /tmp
gzip -d /tmp/ncaa_box_scores_hitting_*.csv.gz

# Embedded tabs
rpl -e '\t,' ',' /tmp/ncaa_box_scores_hitting_2016_3.csv

tail -q -n+2 /tmp/ncaa_box_scores_hitting_201[45]_?.csv >> /tmp/box_scores.csv
tail -q -n+2 /tmp/ncaa_box_scores_hitting_201[6]_?.csv | awk -F'\t' 'NF==25{print}{}' >> /tmp/box_scores.csv

psql baseball -f loaders/load_box_scores_hitting_2014-2016.sql
rm /tmp/box_scores.csv
rm /tmp/ncaa_box_scores_hitting_*.csv

# Box scores - hitting 2013

echo
echo "Box scores - hitting 2013"
echo

cp csv/ncaa_box_scores_hitting_2013*.csv.gz /tmp
gzip -d /tmp/ncaa_box_scores_hitting_*.csv.gz
tail -q -n+2 /tmp/ncaa_box_scores_hitting_*.csv >> /tmp/box_scores.csv
psql baseball -f loaders/load_box_scores_hitting_2013.sql
rm /tmp/box_scores.csv
rm /tmp/ncaa_box_scores_hitting_*.csv

# Box scores - hitting 2012

echo
echo "Box scores - hitting 2012"
echo

cp csv/ncaa_box_scores_hitting_2012*.csv.gz /tmp
gzip -d /tmp/ncaa_box_scores_hitting_*.csv.gz
tail -q -n+2 /tmp/ncaa_box_scores_hitting_*.csv >> /tmp/box_scores.csv
psql baseball -f loaders/load_box_scores_hitting_2012.sql
rm /tmp/box_scores.csv
rm /tmp/ncaa_box_scores_hitting_*.csv

# Box scores - pitching 2017

echo
echo "Box scores - pitching 2017"
echo

cp csv/ncaa_box_scores_pitching_201[7]_?.csv.gz /tmp
gzip -d /tmp/ncaa_box_scores_pitching_*_?.csv.gz
tail -q -n+2 /tmp/ncaa_box_scores_pitching_*_?.csv >> /tmp/box_scores.csv
rpl -q '""' '' /tmp/box_scores.csv
psql baseball -f loaders/load_box_scores_pitching.sql
rm /tmp/box_scores.csv
rm /tmp/ncaa_box_scores_pitching_*_?.csv

# Box scores - pitching 2016

echo
echo "Box scores - pitching 2016"
echo

cp csv/ncaa_box_scores_pitching_201[6]_?.csv.gz /tmp
gzip -d /tmp/ncaa_box_scores_pitching_*_?.csv.gz
tail -q -n+2 /tmp/ncaa_box_scores_pitching_*_?.csv >> /tmp/box_scores.csv
rpl -q '""' '' /tmp/box_scores.csv
psql baseball -f loaders/load_box_scores_pitching_2016.sql
rm /tmp/box_scores.csv
rm /tmp/ncaa_box_scores_pitching_*_?.csv

# Box scores - pitching 2012-2015

echo
echo "Box scores - pitching 2012-2015"
echo

cp csv/ncaa_box_scores_pitching_201[2345]_?.csv.gz /tmp
gzip -d /tmp/ncaa_box_scores_pitching_201[2345]_?.csv.gz
tail -q -n+2 /tmp/ncaa_box_scores_pitching_201[2345]_?.csv >> /tmp/box_scores.csv
psql baseball -f loaders/load_box_scores_pitching_2012-2015.sql
rm /tmp/box_scores.csv
rm /tmp/ncaa_box_scores_pitching_201[2345]_?.csv

# Box scores - fielding 2017

echo
echo "Box scores - fielding 2017"
echo

cp csv/ncaa_box_scores_fielding_201[7]_?.csv.gz /tmp
gzip -d /tmp/ncaa_box_scores_fielding_*.csv.gz
tail -q -n+2 /tmp/ncaa_box_scores_fielding_*.csv >> /tmp/box_scores.csv
psql baseball -f loaders/load_box_scores_fielding.sql
rm /tmp/box_scores.csv
rm /tmp/ncaa_box_scores_fielding_*.csv

# Box scores - fielding 2014-2016

echo
echo "Box scores - fielding 2014-2016"
echo

cp csv/ncaa_box_scores_fielding_201[456]_?.csv.gz /tmp
gzip -d /tmp/ncaa_box_scores_fielding_*.csv.gz
tail -q -n+2 /tmp/ncaa_box_scores_fielding_*.csv >> /tmp/box_scores.csv
psql baseball -f loaders/load_box_scores_fielding_2014-2016.sql
rm /tmp/box_scores.csv
rm /tmp/ncaa_box_scores_fielding_*.csv

# Box scores - fielding 2012-2013

echo
echo "Box scores - fielding 2012-2013"
echo

cp csv/ncaa_box_scores_fielding_201[23]*.csv.gz /tmp
gzip -d /tmp/ncaa_box_scores_fielding_*.csv.gz
tail -q -n+2 /tmp/ncaa_box_scores_fielding_*.csv >> /tmp/box_scores.csv
psql baseball -f loaders/load_box_scores_fielding_2012-2013.sql
rm /tmp/box_scores.csv
rm /tmp/ncaa_box_scores_fielding_*.csv

# Player summaries - hitting 2016-2017

echo
echo "Player summaries - hitting 2016-2017"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_201[67]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_hitting.sql
rm /tmp/player_summaries.csv

# Player summaries - hitting 2015

echo
echo "Player summaries - hitting 2015"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_201[5]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_hitting_2015.sql
rm /tmp/player_summaries.csv

# Player summaries - hitting 2014

echo
echo "Player summaries - hitting 2014"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_2014_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_hitting_2014.sql
rm /tmp/player_summaries.csv

# Player summaries - hitting 2013

echo
echo "Player summaries - hitting 2013"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_2013_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_hitting_2013.sql
rm /tmp/player_summaries.csv

# Player summaries - hitting 2012

echo
echo "Player summaries - hitting 2012"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_2012_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_hitting_2012.sql
rm /tmp/player_summaries.csv

# Player summaries - pitching 2017

echo
echo "Player summaries - pitching 2017"
echo

tail -q -n+2 csv/ncaa_player_summaries_pitching_201[7]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_pitching.sql
rm /tmp/player_summaries.csv

# Player summaries - pitching 2016

echo
echo "Player summaries - pitching 2016"
echo

tail -q -n+2 csv/ncaa_player_summaries_pitching_201[6]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_pitching_2016.sql
rm /tmp/player_summaries.csv

# Player summaries - pitching 2015

echo
echo "Player summaries - pitching 2015"
echo

tail -q -n+2 csv/ncaa_player_summaries_pitching_201[5]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_pitching_2015.sql
rm /tmp/player_summaries.csv

# Player summaries - pitching 2012-2014

echo
echo "Player summaries - pitching 2012-2014"
echo

tail -q -n+2 csv/ncaa_player_summaries_pitching_201[234]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_pitching_2012-2014.sql
rm /tmp/player_summaries.csv

# Player summaries - fielding 2017

echo
echo "Player summaries - fielding 2017"
echo

tail -q -n+2 csv/ncaa_player_summaries_fielding_201[7]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_fielding.sql
rm /tmp/player_summaries.csv

# Player summaries - fielding 2014-2016

echo
echo "Player summaries - fielding 2014-2016"
echo

tail -q -n+2 csv/ncaa_player_summaries_fielding_201[456]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_fielding_2014-2016.sql
rm /tmp/player_summaries.csv

# Player summaries - fielding 2012-2013

echo
echo "Player summaries - fielding 2012-2013"
echo

tail -q -n+2 csv/ncaa_player_summaries_fielding_201[23]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f loaders/load_player_summaries_fielding_2012-2013.sql
rm /tmp/player_summaries.csv

# Team summaries - hitting 2016-2017
# Need to be hand-checked

echo
echo "Team summaries - hitting 2016-2017"
echo

tail -q -n+2 csv/ncaa_team_summaries_hitting_201[67]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_hitting.sql
rm /tmp/team_summaries.csv

# Team summaries - hitting 2015

echo
echo "Team summaries - hitting 2015"
echo

tail -q -n+2 csv/ncaa_team_summaries_hitting_201[5]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_hitting_2015.sql
rm /tmp/team_summaries.csv

# Team summaries - hitting 2014

echo
echo "Team summaries - hitting 2014"
echo

tail -q -n+2 csv/ncaa_team_summaries_hitting_2014_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_hitting_2014.sql
rm /tmp/team_summaries.csv

# Team summaries - hitting 2013

echo
echo "Team summaries - hitting 2013"
echo

tail -q -n+2 csv/ncaa_team_summaries_hitting_2013_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_hitting_2013.sql
rm /tmp/team_summaries.csv

# Team summaries - hitting 2012

echo
echo "Team summaries - hitting 2012"
echo

tail -q -n+2 csv/ncaa_team_summaries_hitting_2012_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_hitting_2012.sql
rm /tmp/team_summaries.csv

# Team summaries - pitching 2017

echo
echo "Team summaries - pitching 2017"
echo

tail -q -n+2 csv/ncaa_team_summaries_pitching_201[7]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_pitching.sql
rm /tmp/team_summaries.csv

# Team summaries - pitching 2016

echo
echo "Team summaries - pitching 2016"
echo

tail -q -n+2 csv/ncaa_team_summaries_pitching_201[6]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_pitching_2016.sql
rm /tmp/team_summaries.csv

# Team summaries - pitching 2015

echo
echo "Team summaries - pitching 2015"
echo

tail -q -n+2 csv/ncaa_team_summaries_pitching_201[5]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_pitching_2015.sql
rm /tmp/team_summaries.csv

# Team summaries - pitching 2012-2014

echo
echo "Team summaries - pitching 2012-2014"
echo

tail -q -n+2 csv/ncaa_team_summaries_pitching_201[234]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_pitching_2012-2014.sql
rm /tmp/team_summaries.csv

# Team summaries - fielding 2017

echo
echo "Team summaries - fielding 2017"
echo

tail -q -n+2 csv/ncaa_team_summaries_fielding_201[7]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_fielding.sql
rm /tmp/team_summaries.csv

# Team summaries - fielding 2014-2016

echo
echo "Team summaries - fielding 2014-2016"
echo

tail -q -n+2 csv/ncaa_team_summaries_fielding_201[456]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_fielding_2014-2016.sql
rm /tmp/team_summaries.csv

# Team summaries - fielding 2012-2013

echo
echo "Team summaries - fielding 2012-2013"
echo

tail -q -n+2 csv/ncaa_team_summaries_fielding_201[23]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f loaders/load_team_summaries_fielding_2012-2013.sql
rm /tmp/team_summaries.csv

# Player splits - hitting 2016-2017

echo
echo "Player splits - hitting 2016-2017"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_201[67]_?_*.csv >> /tmp/player_summaries_splits.csv
rpl -q '""' '' /tmp/player_summaries_splits.csv
rpl -q ' ' '' /tmp/player_summaries_splits.csv
psql baseball -f loaders/load_player_summaries_hitting_splits.sql
rm /tmp/player_summaries_splits.csv

# Player splits - hitting 2015

echo
echo "Player splits - hitting 2015"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_201[5]_?_*.csv >> /tmp/player_summaries_splits.csv
rpl -q '""' '' /tmp/player_summaries_splits.csv
rpl -q ' ' '' /tmp/player_summaries_splits.csv
psql baseball -f loaders/load_player_summaries_hitting_splits_2015.sql
rm /tmp/player_summaries_splits.csv

# Player splits - hitting 2014

echo
echo "Player splits - hitting 2014"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_2014_?_*.csv >> /tmp/player_summaries_splits.csv
rpl -q '""' '' /tmp/player_summaries_splits.csv
rpl -q ' ' '' /tmp/player_summaries_splits.csv
psql baseball -f loaders/load_player_summaries_hitting_splits_2014.sql
rm /tmp/player_summaries_splits.csv

# Player splits - hitting 2013

echo
echo "Player splits - hitting 2013"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_2013_?_*.csv >> /tmp/player_summaries_splits.csv
rpl -q '""' '' /tmp/player_summaries_splits.csv
rpl -q ' ' '' /tmp/player_summaries_splits.csv
psql baseball -f loaders/load_player_summaries_hitting_splits_2013.sql
rm /tmp/player_summaries_splits.csv

# Player splits - hitting 2012

echo
echo "Player splits - hitting 2012"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_2012_?_*.csv >> /tmp/player_summaries_splits.csv
rpl -q '""' '' /tmp/player_summaries_splits.csv
rpl -q ' ' '' /tmp/player_summaries_splits.csv
psql baseball -f loaders/load_player_summaries_hitting_splits_2012.sql
rm /tmp/player_summaries_splits.csv

# Player splits - pitching 2016-2017

echo
echo "Player splits - pitching 2016-2017"
echo

tail -q -n+2 csv/ncaa_player_summaries_pitching_201[67]_?_*.csv >> /tmp/player_summaries_splits.csv
rpl -q '""' '' /tmp/player_summaries_splits.csv
rpl -q ' ' '' /tmp/player_summaries_splits.csv
psql baseball -f loaders/load_player_summaries_pitching_splits.sql
rm /tmp/player_summaries_splits.csv

# Player splits - pitching 2015

echo
echo "Player splits - pitching 2015"
echo

tail -q -n+2 csv/ncaa_player_summaries_pitching_201[5]_?_*.csv >> /tmp/player_summaries_splits.csv
rpl -q '""' '' /tmp/player_summaries_splits.csv
rpl -q ' ' '' /tmp/player_summaries_splits.csv
psql baseball -f loaders/load_player_summaries_pitching_splits_2015.sql
rm /tmp/player_summaries_splits.csv

# Player splits - pitching 2012-2014

echo
echo "Player splits - pitching 2012-2014"
echo

tail -q -n+2 csv/ncaa_player_summaries_pitching_201[234]_?_*.csv >> /tmp/player_summaries_splits.csv
rpl -q '""' '' /tmp/player_summaries_splits.csv
rpl -q ' ' '' /tmp/player_summaries_splits.csv
psql baseball -f loaders/load_player_summaries_pitching_splits_2012-2014.sql
rm /tmp/player_summaries_splits.csv

# Remove commas from some columns, convert to integer

echo
echo "Remove commas from some columns, convert to integer"
echo

psql baseball -f cleaning/commas_psp.sql
psql baseball -f cleaning/commas_tsh.sql
psql baseball -f cleaning/commas_tsp.sql
psql baseball -f cleaning/commas_tsf.sql

# Game periods

echo
echo "Game periods"
echo

tail -q -n+2 csv/ncaa_games_periods_*.csv >> /tmp/periods.csv
rpl "[" "{" /tmp/periods.csv
rpl "]" "}" /tmp/periods.csv
psql baseball -f loaders/load_periods.sql
rm /tmp/periods.csv

# Load play-by-play data 2012-2017

echo
echo "Load play-by-play data 2012-2017"
echo

cp csv/ncaa_games_play_by_play_201[234567]_?.csv.gz /tmp
gzip -d /tmp/ncaa_games_play_by_play_*.csv.gz
tail -q -n+2 /tmp/ncaa_games_play_by_play_*.csv >> /tmp/play_by_play.csv
psql baseball -f loaders/load_play_by_play.sql
rm /tmp/play_by_play.csv
rm /tmp/ncaa_games_play_by_play_*.csv

# Vacuum schema ncaa_pbp

echo "Vacuuming baseball schema ncaa_pbp"
psql -t -A -c "select 'VACUUM '||table_schema||'.'||table_name||';' from information_schema.tables where table_schema = 'ncaa_pbp'" baseball | psql baseball

# Denull tables as needed

echo
echo "Denull tables as needed"
echo

psql baseball -f cleaning/denull_bsp.sql

# Remove duplicate rows

echo
echo "Remove duplicate rows"
echo

psql baseball -f cleaning/deduplicate_periods.sql
psql baseball -c "vacuum ncaa_pbp.periods;"

psql baseball -f cleaning/deduplicate_pbp.sql
psql baseball -c "vacuum ncaa_pbp.play_by_play;"

psql baseball -f cleaning/deduplicate_bsh.sql
psql baseball -c "vacuum ncaa_pbp.box_scores_hitting;"

psql baseball -f cleaning/deduplicate_bsp.sql
psql baseball -c "vacuum ncaa_pbp.box_scores_pitching;"

psql baseball -f cleaning/deduplicate_bsf.sql
psql baseball -c "vacuum ncaa_pbp.box_scores_fielding;"

# Add primary keys and constraints

echo
echo "Add primary keys and constraints"
echo

psql baseball -f cleaning/add_pk_periods.sql
psql baseball -f cleaning/add_pk_pbp.sql
psql baseball -f cleaning/add_pk_bsh.sql
psql baseball -f cleaning/add_pk_bsp.sql
psql baseball -f cleaning/add_pk_bsf.sql

# Create pitch strings table

echo
echo "Create pitch strings table"
echo

psql baseball -f loaders/create_pitch_strings.sql
