#!/bin/bash

./scrapers/njcaa_schools.rb

./scrapers/njcaa_school_rosters.rb &

./scrapers/njcaa_summaries.rb &

./scrapers/njcaa_school_schedules.rb

./scrapers/njcaa_play_by_play.rb
