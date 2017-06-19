begin;

--drop table if exists ncaa_pbp.box_scores_pitching;

create temporary table bsp (
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
);

copy bsp from '/tmp/box_scores.csv' with delimiter as E'\t' csv;

insert into ncaa_pbp.box_scores_pitching
(
game_id,section_id,
player_id,player_name,player_url,
starter,
position,
g,app,gs,
ip,h,r,er,bb,so,sho,bf,
p_oab,d_allowed,t_allowed,hr_allowed,
wp,bk,hb,ibb,inh_run,inh_run_score,sha,sfa,
pitches,go,fo,w,l,sv,ord_appeared,kl)
(
select

game_id,section_id,
player_id,player_name,player_url,
starter,
position,
NULL as g,
app,gs,
ip,h,r,er,bb,so,sho,bf,
p_oab,d_allowed,t_allowed,hr_allowed,
wp,bk,hb,ibb,inh_run,inh_run_score,sha,sfa,
pitches,go,fo,w,l,sv,ord_appeared,kl
from bsp
);

commit;
