begin;

create table if not exists naia.games (
	team_name	      text,
	team_id		      integer,
	parsed_team_id	      integer,
	opponent_id	      integer,
	comp_id		      integer,
	conference_game	      boolean,
	year		      integer,
	game_date	      date,
	opponent_name	      text,
	location	      text,
	score		      text,
	outcome		      text,
	webcast_url	      text
--	primary key (team_id,comp_id)
);

truncate naia.games;

copy naia.games from '/tmp/games.csv' with delimiter as ',' csv quote as '"';

--copy naia.games from '/home/clong/tools/spiders/naia/naia_team_games_2012.csv' with delimiter as ',' csv header quote as '"';

commit;
