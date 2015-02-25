#!/bin/bash

psql baseball -f sos/standardized_results.sql

psql baseball -c "drop table njcaa._basic_factors;"
psql baseball -c "drop table njcaa._parameter_levels;"
psql baseball -c "drop table njcaa._factors;"
psql baseball -c "drop table njcaa._schedule_factors;"

R --vanilla -f sos/njcaa_lmer.R

psql baseball -f sos/normalize_factors.sql
psql baseball -f sos/schedule_factors.sql
