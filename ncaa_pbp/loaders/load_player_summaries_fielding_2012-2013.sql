begin;

--drop table if exists ncaa_pbp.player_summaries_fielding;

create temporary table psf (
       year					integer,
       year_id					integer,
       division_id				integer,
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
--       g					integer,
       po					integer,
       a					integer,
       e					integer,
       fpct					float,
       ci					integer,
       pb					integer,
       sba					integer,
       csb					integer,
       idp					integer,
       tp					integer,
       primary key (year_id,player_id),
       unique (year,player_id)
);

copy psf from '/tmp/player_summaries.csv' with delimiter as E'\t' csv;

insert into ncaa_pbp.player_summaries_fielding
(year,year_id,division_id,team_id,team_name,jersey_number,
 player_id,player_name,player_url,class_year,position,
 gp,gs,g,po,a,e,fpct,ci,pb,sba,csb,idp,tp)
(
select
year,year_id,division_id,team_id,team_name,jersey_number,
player_id,player_name,player_url,class_year,position,
gp,gs,
1 as g,
po,a,e,fpct,ci,pb,sba,csb,idp,tp
from psf
);

commit;
