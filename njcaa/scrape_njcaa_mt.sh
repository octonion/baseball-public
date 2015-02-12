#!/bin/bash

./scrapers/njcaa_schools.rb

./scrapers/njcaa_school_rosters_mt.rb &

./scrapers/njcaa_summaries.rb &

./scrapers/njcaa_school_schedules_mt.rb

./scrapers/njcaa_school_box_scores_mt.rb

./scrapers/njcaa_play_by_play_mt.rb

