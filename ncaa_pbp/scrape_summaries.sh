#!/bin/bash

./scrapers/ncaa_summaries_hitting.rb $1 $2

./scrapers/ncaa_summaries_pitching.rb $1 $2

./scrapers/ncaa_summaries_fielding.rb $1 $2
