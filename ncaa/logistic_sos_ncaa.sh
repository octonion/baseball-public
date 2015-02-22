#!/bin/bash

#psql baseball -c "drop table if exists ncaa.results;"

#psql baseball -f standardized_results.sql

psql baseball -c "vacuum full verbose analyze ncaa.results;"

psql baseball -c "drop table if exists ncaa._basic_factors_logistic;"
psql baseball -c "drop table if exists ncaa._parameter_levels_logistic;"

R --vanilla -f sos/ncaa_lmer_logistic.R

psql baseball -c "vacuum full verbose analyze ncaa._parameter_levels_logistic;"
psql baseball -c "vacuum full verbose analyze ncaa._basic_factors_logistic;"

psql baseball -f sos/normalize_factors_logistic.sql
psql baseball -c "vacuum full verbose analyze ncaa._factors_logistic;"

psql baseball -f sos/schedule_factors_logistic.sql
psql baseball -c "vacuum full verbose analyze ncaa._schedule_factors_logistic;"

psql baseball -f sos/current_ranking_logistic.sql > sos/current_ranking_logistic.txt
psql baseball -f sos/division_ranking_logistic.sql > sos/division_ranking_logistic.txt
