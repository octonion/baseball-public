#!/bin/bash

psql baseball -f sos/standardized_results.sql

psql baseball -c "drop table naia._basic_factors;"
psql baseball -c "drop table naia._parameter_levels;"
psql baseball -c "drop table naia._factors;"
psql baseball -c "drop table naia._schedule_factors;"

R --vanilla -f sos/naia_lmer.R

psql baseball -f sos/normalize_factors.sql
psql baseball -f sos/schedule_factors.sql

psql baseball -f sos/current_ranking.sql > sos/current_ranking.txt
