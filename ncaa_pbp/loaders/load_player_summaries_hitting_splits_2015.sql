begin;

--drop table if exists ncaa_pbp.player_summaries_hitting_splits;

create temporary table pshs (
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
       ba					float,
       obp					float,
       slg					float,
       r					integer,
       ab					integer,
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
--       primary key (year_id,player_id,split_id)
--       unique (year,player_id)
);

copy pshs from '/tmp/player_summaries_splits.csv' with delimiter as E'\t' csv;

insert into ncaa_pbp.player_summaries_hitting_splits
(
year,year_id,division_id,
split_name,split_id,
team_id,team_name,jersey_number,
player_id,player_name,player_url,class_year,position,
gp,gs,g,ba,obp,slg,ab,r,h,d,t,tb,hr,rbi,bb,hbp,sf,sh,k,dp,sb,cs,picked)
(
select
year,year_id,division_id,
split_name,split_id,
team_id,team_name,jersey_number,
player_id,player_name,player_url,class_year,position,
gp,gs,g,ba,obp,slg,ab,r,h,d,t,tb,hr,rbi,bb,hbp,sf,sh,k,dp,sb,cs,picked
from pshs
);

commit;
