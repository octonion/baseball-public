begin;

drop table if exists ncaa.conferences_teams;

create table ncaa.conferences_teams (
       year  		      integer,
       division_id	      integer,
       ranking_id	      integer,
       conference_key	      text,
       conference_id	      integer,
       team_id		      integer,
       team_name	      text,
       primary key (year,team_id)
);

copy ncaa.conferences_teams from '/tmp/conferences_teams.tsv' with delimiter as E'\t' csv header;

commit;
