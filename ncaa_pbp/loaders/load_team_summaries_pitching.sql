begin;

drop table if exists ncaa_pbp.team_summaries_pitching;

create table ncaa_pbp.team_summaries_pitching (
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
       app					integer,
       gs2					text,
       era					float,
       ip					text,
       h					integer,
       r					integer,
       er					integer,
       bb					integer,
       so					integer,
       sho					integer,
       bf					text,
       p_oab					text,
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
       kl					integer,
       primary key (year_id,team_id,player_name),
       unique (year,team_id,player_name)
);

copy ncaa_pbp.team_summaries_pitching from '/tmp/team_summaries.csv' with delimiter as E'\t' csv;

commit;
