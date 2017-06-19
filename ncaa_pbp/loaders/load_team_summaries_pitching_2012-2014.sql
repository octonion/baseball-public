begin;

create temporary table tsp (
       year					integer,
       year_id					integer,
--       division_id				integer,
       team_id					integer,
       team_name				text,
       jersey_number				text,
--       player_id				integer,
       player_name				text,
--       player_url				text,
       class_year				text,
       position					text,
       gp					integer,
       gs					integer,
       app					integer,
       gs2					integer,
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
       kl					integer
--       primary key (year_id, player_id)
--       unique (year, player_id)
);

copy tsp from '/tmp/team_summaries.csv' with delimiter as E'\t' csv;

insert into ncaa_pbp.team_summaries_pitching
(
year,year_id,
team_id,team_name,jersey_number,
player_name,class_year,position,
gp,gs,
g,
app,gs2,
era,ip,h,r,er,bb,so,sho,bf,
p_oab,d_allowed,t_allowed,hr_allowed,
wp,bk,hb,ibb,inh_run,inh_run_score,sha,sfa,
pitches,go,fo,w,l,sv,kl)
(
select
year,year_id,
team_id,team_name,jersey_number,
player_name,class_year,position,
gp,gs,
NULL as g,
app,gs2,
era,ip,h,r,er,bb,so,sho,bf,
p_oab,d_allowed,t_allowed,hr_allowed,
wp,bk,hb,ibb,inh_run,inh_run_score,sha,sfa,
pitches,go,fo,w,l,sv,kl
from tsp
);

commit;
