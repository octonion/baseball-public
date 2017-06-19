#!/bin/bash

# Update player summaries - hitting 2016

echo
echo "Update player summaries - hitting 2016"
echo

tail -q -n+2 csv/ncaa_player_summaries_hitting_201[6]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f updaters/update_player_summaries_hitting.sql
rm /tmp/player_summaries.csv

# Update player summaries - pitching 2016

echo
echo "Update player summaries - pitching 2016"
echo

tail -q -n+2 csv/ncaa_player_summaries_pitching_201[6]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f updaters/update_player_summaries_pitching.sql
rm /tmp/player_summaries.csv

# Update player summaries - fielding 2016

echo
echo "Update player summaries - fielding 2016"
echo

tail -q -n+2 csv/ncaa_player_summaries_fielding_201[6]_?.csv >> /tmp/player_summaries.csv
rpl -q '""' '' /tmp/player_summaries.csv
rpl -q ' ' '' /tmp/player_summaries.csv
psql baseball -f updaters/update_player_summaries_fielding.sql
rm /tmp/player_summaries.csv

# Update team summaries - hitting 2016

echo
echo "Update team summaries - hitting 2016"
echo

tail -q -n+2 csv/ncaa_team_summaries_hitting_201[6]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f updaters/update_team_summaries_hitting.sql
rm /tmp/team_summaries.csv

# Update team summaries - pitching 2016

echo
echo "Update team summaries - pitching 2016"
echo

tail -q -n+2 csv/ncaa_team_summaries_pitching_201[6]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f updaters/update_team_summaries_pitching.sql
rm /tmp/team_summaries.csv

# Update team summaries - fielding 2016

echo
echo "Update team summaries - fielding 2016"
echo

tail -q -n+2 csv/ncaa_team_summaries_fielding_201[6]_?.csv >> /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -e '\t-\t' '\t\t' /tmp/team_summaries.csv
rpl -q '""' '' /tmp/team_summaries.csv
rpl -q ' ' '' /tmp/team_summaries.csv
psql baseball -f updaters/update_team_summaries_fielding.sql
rm /tmp/team_summaries.csv
