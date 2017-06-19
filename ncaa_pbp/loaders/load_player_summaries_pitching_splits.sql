begin;

drop table if exists ncaa_pbp.player_summaries_pitching_splits;

create table ncaa_pbp.player_summaries_pitching_splits (
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
       app					integer,
       gs2					integer,
       era					float,
       ip					text,
       cg					integer,
       h					integer,
       r					integer,
       er					integer,
       bb					integer,
       so					integer,
       sho					integer,
       bf					integer,
       p_oab					integer,
       d_allowed				integer,
       t_allowed				integer,
       hr_allowed				integer,
       wp					integer,
       bk					integer,
       hb					integer,
       ibb					integer,
       inh_run					integer,
       inh_run_score				integer,
       sha					integer,
       sfa					integer,
       pitches					text,
       go					integer,
       fo					integer,
       w					integer,
       l					integer,
       sv					integer,
       kl					integer
--       primary key (year_id, player_id, split_id)
--       unique (year, player_id)
);

copy ncaa_pbp.player_summaries_pitching_splits from '/tmp/player_summaries_splits.csv' with delimiter as E'\t' csv;

commit;
