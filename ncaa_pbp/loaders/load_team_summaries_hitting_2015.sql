begin;

create temporary table tsh (
       year					integer,
       year_id					integer,
--       division_id				integer,
       team_id					integer,
       team_name				text,
       jersey_number				text,
       player_name				text,
       class_year				text,
       position					text,
       gp					integer,
       gs					integer,
       g					integer,
       ba					float,
       obp					float,
       slg					float,
       r					integer,
       ab					text,
       h					integer,
       d					integer,
       t					integer,
       tb					text,
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
       primary key (year_id,team_id,player_name),
       unique (year,team_id,player_name)
);

copy tsh from '/tmp/team_summaries.csv' with delimiter as E'\t' csv;

insert into ncaa_pbp.team_summaries_hitting
(year,year_id,team_id,team_name,jersey_number,
 player_name,class_year,position,
 gp,gs,g,ba,obp,slg,ab,r,h,d,t,tb,hr,rbi,bb,hbp,sf,sh,k,dp,sb,cs,picked)
(
select
year,year_id,team_id,team_name,jersey_number,
player_name,class_year,position,
gp,gs,
g,
ba,obp,slg,ab,r,h,d,t,tb,hr,rbi,bb,hbp,sf,sh,k,dp,sb,cs,picked
from tsh
);

commit;
