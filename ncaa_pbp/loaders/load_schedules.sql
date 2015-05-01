begin;

drop table if exists ncaa_pbp.team_schedules;

create table ncaa_pbp.team_schedules (
	year		      integer,
	year_id		      integer,
	team_id		      integer,
        team_name	      text,
        game_date	      date,
	game_string	      text,
	opponent_id	      integer,
	opponent_name	      text,
	opponent_url	      text,
	neutral_site	      boolean,
	neutral_location      text,
	home_game	      boolean,
	score_string	      text,
	team_won	      boolean,
	score		      text,
	team_score	      integer,
	opponent_score	      integer,
	overtime	      boolean,
	overtime_periods      text,
	game_id		      integer,
	game_url	      text
);

truncate table ncaa_pbp.team_schedules;

copy ncaa_pbp.team_schedules from '/tmp/schedules.csv' with delimiter as E'\t' csv;

--alter table ncaa.games add column game_id serial primary key;

--update ncaa.games
--set game_length = trim(both ' -' from game_length);

commit;
