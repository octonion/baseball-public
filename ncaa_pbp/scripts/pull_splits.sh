#!/bin/bash

./scrapers/ncaa_summaries_hitting_splits.rb $1 $2 vs_lhp
./scrapers/ncaa_summaries_hitting_splits.rb $1 $2 vs_rhp

./scrapers/ncaa_summaries_pitching_splits.rb $1 $2 vs_lhb
./scrapers/ncaa_summaries_pitching_splits.rb $1 $2 vs_rhb
