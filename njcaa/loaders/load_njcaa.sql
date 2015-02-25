begin;

create schema if not exists njcaa;

drop table if exists njcaa.games;

create table njcaa.games (
	division_id	      integer,
	game_date	      date,
	pulled_date	      date,
	visitor_name	      text,
	visitor_id	      integer,
	visitor_college_id    integer,
	visitor_href	      text,
	visitor_record	      text,
	visitor_score	      integer,
	park_name	      text,
	home_name	      text,
	home_id		      integer,
	home_college_id	      integer,
	home_href	      text,
	home_record	      text,
	home_score	      integer,
	status		      text
);

copy njcaa.games from '/tmp/njcaa_games.csv'
with delimiter as ',' csv quote as '"';

create index on njcaa.games (visitor_college_id);
create index on njcaa.games (home_college_id);

alter table njcaa.games add column visitor_div_id integer;

alter table njcaa.games add column home_div_id integer;

update njcaa.games
set home_div_id=divid
from njcaa.teams
where teams.collegeid=home_college_id;

update njcaa.games
set visitor_div_id=divid
from njcaa.teams
where teams.collegeid=visitor_college_id;

commit;
