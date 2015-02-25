begin;

create schema if not exists njcaa;

drop table if exists njcaa.teams;

create table njcaa.teams (
	divid		      integer,
	team_name	      text,
	team_href	      text,
	sid		      integer,
	collegeid	      integer,
	slid		      integer,
	primary key (collegeid)
);

truncate table njcaa.teams;

copy njcaa.teams from '/tmp/njcaa_teams.csv'
with delimiter as ',' csv quote as '"';

commit;
