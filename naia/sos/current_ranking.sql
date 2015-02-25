begin;

create temporary table r (
       rk	 serial,
       team 	 text,
       team_id	 integer,
       year	 integer,
       str	 numeric(4,3),
       park	 numeric(4,3),
       ofs	 numeric(4,3),
       dfs	 numeric(4,3),
       sos	 numeric(4,3)
);

insert into r
(team,team_id,year,str,park,ofs,dfs,sos)
(
select
t.team_name,
sf.team_id,
sf.year,
sf.strength::numeric(4,3) as str,
park::numeric(4,3) as park,
offensive::numeric(4,3) as ofs,
defensive::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from naia._schedule_factors sf
left outer join naia.teams t
  on (t.team_id,t.year)=(sf.team_id,sf.year)
where sf.year in (2014)
order by str desc);

select
rk,team,year,str,park,ofs,dfs,sos
from r
where year in (2014)
order by rk asc;

commit;
