begin;

--drop table if exists ncaa_pbp.team_summaries_fielding;

create temporary table tsf (
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
       g					integer,
       po					text,
       a					integer,
       e					integer,
       fpct					float,
       ci					integer,
       pb					integer,
       sba					integer,
       csb					integer,
       idp					integer,
       tp					integer,
       primary key (year_id,team_id,player_name),
       unique (year,team_id,player_name)
);

copy tsf from '/tmp/team_summaries.csv' with delimiter as E'\t' csv;

insert into ncaa_pbp.team_summaries_fielding
(year,year_id,team_id,team_name,jersey_number,
 player_name,class_year,position,
 gp,gs,g,po,a,e,fpct,ci,pb,sba,csb,idp,tp)
(
select
year,year_id,team_id,team_name,jersey_number,
player_name,class_year,position,
gp,gs,g,po,a,e,fpct,ci,pb,sba,csb,idp,tp
from tsf
);

commit;
