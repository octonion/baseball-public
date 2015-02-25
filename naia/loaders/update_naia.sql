begin;

delete from naia.games where extract(year from game_date) in (2012);

copy naia.games from '/home/clong/tools/spiders/naia/naia_games_2012.csv' csv header;

commit;
