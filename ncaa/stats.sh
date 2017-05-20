#!/bin/bash

tail -q -n+2 csv/ncaa_games_mt_*.csv >> /tmp/games.csv

tail -q -n+2 csv/ncaa_player_statistics_mt_20??.csv >> /tmp/ncaa_player_statistics.csv

rpl -e ".\t" "\t" /tmp/ncaa_player_statistics.csv
rpl -e ".0\t" "\t" /tmp/ncaa_player_statistics.csv
rpl -e ".00\t" "\t" /tmp/ncaa_player_statistics.csv
rpl -e ".000\t" "\t" /tmp/ncaa_player_statistics.csv
psql baseball -f loaders/load_ncaa_player_statistics.sql
rm /tmp/ncaa_player_statistics.csv
