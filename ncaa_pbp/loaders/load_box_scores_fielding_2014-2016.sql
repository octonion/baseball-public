begin;

--drop table if exists ncaa_pbp.box_scores_fielding;

create temporary table bsf (
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
);

copy bsf from '/tmp/box_scores.csv' with delimiter as E'\t' csv;

insert into ncaa_pbp.box_scores_fielding
(
game_id,section_id,player_id,player_name,player_url,
starter,position,
g,po,a,e,ci,pb,sba,csb,idp,tp)
(
select
game_id,section_id,player_id,player_name,player_url,
starter,position,
g,po,a,e,ci,pb,sba,csb,idp,tp
from bsf
);

commit;
