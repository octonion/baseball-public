begin;

drop table if exists ncaa_pbp.periods;

create table ncaa_pbp.periods (
	game_id		      integer,
	section_id	      integer,
	team_id		      integer,
	team_name	      text,
	team_url	      text,
	period_scores	      integer[]

	--Need to deduplicate first
	--primary key
	--  primary key (game_id,section_id),
	--(game_id,section_id) must also be unique
	--  unique (game_id,team_id)
);

copy ncaa_pbp.periods from '/tmp/periods.csv' with delimiter as E'\t' csv;

commit;
