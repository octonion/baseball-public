#!/bin/sh

unset CDPATH

cp ../../spiders/naia/*games_2012.csv .

yes | rpl -e '\r\n' '' *.csv

psql baseball -f update_naia.sql

rm -f *games_2012.csv

exit 1
