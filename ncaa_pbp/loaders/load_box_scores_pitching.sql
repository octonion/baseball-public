begin;

drop table if exists ncaa_pbp.box_scores_pitching;

create table ncaa_pbp.box_scores_pitching (
       game_id					integer,
       section_id				integer,
       player_id				integer,
       player_name				text,
       player_url				text,
       starter					boolean,
       position					text,
       app					integer,
       gs					integer,
       ip					text,
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
       pitches					integer,
       go					integer,
       fo					integer,
       w					integer,
       l					integer,
       sv					integer,
       ord_appeared				integer,
       kl					integer
       
-- This will fail if the two teams are in different divisions
-- Best fix?
--       primary key (game_id, section_id, player_name, position)
);

copy ncaa_pbp.box_scores_pitching from '/tmp/box_scores.csv' with delimiter as E'\t' csv;

commit;
