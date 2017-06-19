#!/bin/bash

#./scrapers/ncaa_years.rb

#year=$1
#division=$2

./scrapers/ncaa_team_rosters.rb $1 $2

./scrapers/ncaa_summaries_hitting.rb $1 $2

./scrapers/ncaa_summaries_pitching.rb $1 $2

./scrapers/ncaa_summaries_fielding.rb $1 $2

./scrapers/ncaa_team_schedules.rb $1 $2

./scrapers/ncaa_box_scores_hitting.rb $1 $2

./scrapers/ncaa_box_scores_pitching.rb $1 $2

./scrapers/ncaa_box_scores_fielding.rb $1 $2

./scrapers/ncaa_play_by_play.rb $1 $2
