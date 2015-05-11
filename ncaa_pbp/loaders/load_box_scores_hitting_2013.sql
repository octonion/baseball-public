begin;

--drop table if exists ncaa_pbp.box_scores_hitting;

create temporary table bsh (
       game_id					integer,
       section_id				integer,
       player_id				integer,
       player_name				text,
       player_url				text,
       starter					boolean,
       position					text,
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
       picked					integer
--       primary key (game_id, section_id, player_name, position)

);

copy bsh from '/tmp/box_scores.csv' with delimiter as E'\t' csv;

insert into ncaa_pbp.box_scores_hitting
(game_id,section_id,player_id,player_name,player_url,starter,position,
 g,ab,r,h,d,t,tb,hr,rbi,bb,hbp,sf,sh,k,dp,sb,cs,picked)
(
select
game_id,section_id,player_id,player_name,player_url,starter,position,
1 as g,
ab,r,h,d,t,tb,hr,rbi,bb,hbp,sf,sh,k,dp,sb,cs,picked
from bsh
);

commit;
