--drop schema if exists ncaa_json cascade;

create schema if not exists ncaa_json;

create table if not exists ncaa_json.games (
       game_id		     integer,
       game_date	     date,
       gameinfo		     jsonb,
       boxscore		     jsonb,
       pbp		     jsonb
-- Need to check primary key situation
--       primary key (game_id,game_date)
);

truncate table ncaa_json.games;

copy ncaa_json.games from '/tmp/games.csv' csv;
