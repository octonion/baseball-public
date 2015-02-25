begin;

create temporary table r (
       rk	 serial,
       team 	 text,
       team_id	 integer,
       div	 integer,
       year	 integer,
       str	 numeric(4,3),
--       h_div	 numeric(4,3),
--       p_div	 numeric(4,3),
       park	 numeric(4,3),
       ofs	 numeric(4,3),
       dfs	 numeric(4,3),
       sos	 numeric(4,3)
);

insert into r
(team,team_id,div,year,str,park,ofs,dfs,sos)
(
select
t.team_name,
sf.team_id,
t.divid,
sf.year,
(sf.strength*h.exp_factor/p.exp_factor)::numeric(4,3) as str,
park::numeric(4,3) as park,
offensive::numeric(4,3) as ofs,
defensive::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from njcaa._schedule_factors sf
join njcaa.teams t
  on (t.collegeid)=(sf.team_id)
join ncaa._factors h
  on (h.parameter,h.level::integer)=('h_div',t.divid)
join ncaa._factors p
  on (p.parameter,p.level::integer)=('p_div',t.divid)
where sf.year in (2012)
order by str desc);

--copy
--(
select
rk,team,div,str,park,ofs,dfs,sos
from r
where year in (2012)
order by rk asc;
--)
--to '/tmp/ranking.csv' header csv;

commit;
