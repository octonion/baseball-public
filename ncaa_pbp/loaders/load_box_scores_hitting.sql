begin;

drop table if exists ncaa_pbp.box_scores_hitting;

create table ncaa_pbp.box_scores_hitting (
       game_id					integer,
       section_id				integer,
       player_id				integer,
       player_name				text,
       player_url				text,
       starter					boolean,
       position					text,
       g					integer,
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
       primary key (game_id, section_id, player_name, position)
);

copy ncaa_pbp.box_scores_hitting from '/tmp/box_scores.csv' with delimiter as E'\t' csv;

commit;
