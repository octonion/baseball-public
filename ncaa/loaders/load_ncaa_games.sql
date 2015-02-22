begin;

drop table if exists ncaa.games;
create table ncaa.games (
	year		      integer,
	school_name	      text,
	school_id	      integer,
	opponent_name	      text,
	opponent_id	      integer,
	game_date	      date,
	school_score	      integer,
	opponent_score	      integer,
	site	      	      text,
	neutral_site_location text,
	game_length	      text,
	attendance	      text
);

drop table if exists ncaa.records;
create table ncaa.records (
	school_id	      integer,
	school_name	      text,
	year		      integer,
	wins		      integer,
	losses		      integer,
	ties		      integer,
	games		      integer
);

copy ncaa.games from '/tmp/games.csv' with delimiter as ',' csv quote as '"';

--copy ncaa.records from '/home/clong/tools/data_agents/ncaa/records/ncaa_records_2011.csv' with delimiter as ',' csv quote as '"';

commit;
