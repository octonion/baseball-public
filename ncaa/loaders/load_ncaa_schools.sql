begin;

drop table if exists ncaa.schools;
create table ncaa.schools (
       school_id	integer,
       school_name	text,
       primary key (school_id)
);

--create table ncaa.teams (
--       div_id		integer,
--       team_id		integer,
--       team		text,
--       primary key (team_id)
--);

copy ncaa.schools from '/tmp/ncaa_schools.csv' csv header;
--copy ncaa.teams from '/home/clong/tools/parsers/ncaa/ncaa_teams.csv' csv header;

commit;
