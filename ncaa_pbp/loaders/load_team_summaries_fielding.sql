begin;

drop table if exists ncaa_pbp.team_summaries_fielding;

create table ncaa_pbp.team_summaries_fielding (
       year					integer,
       year_id					integer,
       team_id					integer,
       team_name				text,
       jersey_number				text,
       player_name				text,
       class_year				text,
       position					text,
       gp					integer,
       gs					integer,
       g					integer,
       po					text,
       a					integer,
       e					integer,
       fpct					float,
       ci					integer,
       pb					integer,
       sba					integer,
       csb					integer,
       idp					integer,
       tp					integer,
       primary key (year,team_id,player_name),
       unique (year_id,team_id,player_name)
);

copy ncaa_pbp.team_summaries_fielding from '/tmp/team_summaries.csv' with delimiter as E'\t' csv;

commit;
