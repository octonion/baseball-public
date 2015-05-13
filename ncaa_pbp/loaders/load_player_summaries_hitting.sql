begin;

drop table if exists ncaa_pbp.player_summaries_hitting;

create table ncaa_pbp.player_summaries_hitting (
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
       ba					float,
       obp					float,
       slg					float,
       ab					integer,
       r					integer,
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
       sb					integer,
       cs					integer,
       picked					integer,
       primary key (year_id, player_id),
       unique (year, player_id)
);

copy ncaa_pbp.player_summaries_hitting from '/tmp/player_summaries.csv' with delimiter as E'\t' csv;

commit;
