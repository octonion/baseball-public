begin;

drop table if exists ncaa_pbp.box_scores_fielding;

create table ncaa_pbp.box_scores_fielding (
       game_id					integer,
       section_id				integer,
       player_id				integer,
       player_name				text,
       player_url				text,
       starter					boolean,
       position					text,
       g					integer,
       po					integer,
       a					integer,
       e					integer,
       ci					integer,
       pb					integer,
       sba					integer,
       csb					integer,
       idp					integer,
       tp					integer
       
-- This will fail if the two teams are in different divisions
-- Best fix?
--       primary key (game_id, section_id, player_name, position)
);

copy ncaa_pbp.box_scores_fielding from '/tmp/box_scores.csv' with delimiter as E'\t' csv;

commit;
