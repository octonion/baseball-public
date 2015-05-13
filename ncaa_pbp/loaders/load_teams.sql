begin;

drop table if exists ncaa_pbp.teams;

create table ncaa_pbp.teams (
	sport_code	      text,
	year		      integer,
	year_id		      integer,
	division_id	      integer,
	team_id		      integer,
        team_name	      text,
	team_url	      text,
	primary key (sport_code,year_id,team_id),
	unique (sport_code,year,team_id)
);

copy ncaa_pbp.teams from '/tmp/teams.csv' with delimiter as E'\t' csv;

commit;
