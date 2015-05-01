begin;

drop table if exists ncaa_pbp.team_rosters;

create table ncaa_pbp.team_rosters (
	year		      integer,
	year_id		      integer,
	division_id	      integer,
	team_id		      integer,
        team_name	      text,
        jersey_number	      text,
	player_id	      text,
	player_name	      text,
	player_url	      text,
	position	      text,
	class_year	      text,
	games_played	      integer,
	game_started	      integer
);

copy ncaa_pbp.team_rosters from '/tmp/rosters.csv' with delimiter as E'\t' csv;

alter table ncaa_pbp.team_rosters add column ncaa_id integer;

update ncaa_pbp.team_rosters
set ncaa_id=(split_part(player_id,'.',1))::integer;

alter table ncaa_pbp.team_rosters add column hashed_name text;
alter table ncaa_pbp.team_rosters add column id serial;

commit;
