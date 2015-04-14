#!/bin/bash

psql baseball -c "drop table if exists ncaa.results;"

psql baseball -f sos/standardized_results.sql

psql baseball -c "vacuum full verbose analyze ncaa.results;"

psql baseball -c "drop table if exists ncaa._basic_factors;"
psql baseball -c "drop table if exists ncaa._parameter_levels;"

R --vanilla -f sos/ncaa_lmer.R

psql baseball -c "vacuum full verbose analyze ncaa._parameter_levels;"
psql baseball -c "vacuum full verbose analyze ncaa._basic_factors;"

psql baseball -f sos/normalize_factors.sql
psql baseball -c "vacuum full verbose analyze ncaa._factors;"

psql baseball -f sos/schedule_factors.sql
psql baseball -c "vacuum full verbose analyze ncaa._schedule_factors;"

psql baseball -f sos/current_ranking.sql > sos/current_ranking.txt
cp /tmp/current_ranking.csv sos
cp /tmp/2015_d?.csv sos

psql baseball -f sos/division_ranking.sql > sos/division_ranking.txt

psql baseball -f sos/connectivity.sql > sos/connectivity.txt
