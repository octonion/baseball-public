begin;

drop table if exists ncaa_pbp.player_summaries_hitting_splits;

create table ncaa_pbp.player_summaries_hitting_splits (
       year					integer,
       year_id					integer,
       division_id				integer,
       split_name				text,
       split_id					integer,
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
       ba					float,
       obp					float,
       slg					float,
       r					integer,
       ab					integer,
       h					integer,
       d					integer,
       t					integer,
       tb					integer,
       hr					integer,
       rbi					integer,
       bb					integer,
       hbp					integer,
       sf					integer,
       sh					integer,
       k					integer,
       dp					integer,
       cs					integer,
       picked					integer,
       sb					integer,
       rbi2out					integer
--       primary key (year_id,player_id,split_id)
--       unique (year,player_id)
);

copy ncaa_pbp.player_summaries_hitting_splits from '/tmp/player_summaries_splits.csv' with delimiter as E'\t' csv;

commit;
