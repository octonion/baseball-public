begin;

drop table if exists ncaa_pbp.player_summaries_fielding;

create table ncaa_pbp.player_summaries_fielding (
       year					integer,
       year_id					integer,
       division_id				integer,
       team_id					integer,
       team_name				text,
       jersey_number				text,
       player_id				integer,
       player_name				text,
       player_url				text,
       class_year				text,
       position					text,
       gp					integer,
       gs					integer,
       g					integer,
       po					integer,
       a					integer,
       e					integer,
       fpct					float,
       ci					integer,
       pb					integer,
       sba					integer,
       csb					integer,
       idp					integer,
       tp					integer,
       primary key (year_id, player_id),
       unique (year, player_id)
);

copy ncaa_pbp.player_summaries_fielding from '/tmp/player_summaries.csv' with delimiter as E'\t' csv;

commit;
