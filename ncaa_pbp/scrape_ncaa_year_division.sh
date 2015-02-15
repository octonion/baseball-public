#!/bin/bash

#./scrapers/ncaa_years.rb

#year=$1
#division=$2

./scrapers/ncaa_team_rosters.rb $1 $2

./scrapers/ncaa_summaries.rb $1 $2

./scrapers/ncaa_team_schedules.rb $1 $2

./scrapers/ncaa_games_box_scores.rb $1 $2

./scrapers/ncaa_games_play_by_play.rb $1 $2
