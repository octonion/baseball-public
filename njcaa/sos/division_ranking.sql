begin;

create temporary table r (
       school_id	 integer,
       d	 	 integer,
       year	 	 integer,
       str	 	 numeric(4,3),
       park	 	 numeric(4,3),
       ofs	 	 numeric(4,3),
       dfs	 	 numeric(4,3),
       sos	 	 numeric(4,3)
);

insert into r
(school_id,d,year,str,park,ofs,dfs,sos)
(
select
t.collegeid,
t.divid as d,
sf.year,
(sf.strength*h.exp_factor/p.exp_factor)::numeric(4,3) as str,
park::numeric(4,3) as park,
(offensive*h.exp_factor)::numeric(4,3) as ofs,
(defensive*p.exp_factor)::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from njcaa._schedule_factors sf
left outer join njcaa.teams t
  on (t.collegeid)=(sf.team_id)
left outer join njcaa._factors h
  on (h.parameter,h.level::integer)=('h_div',t.divid)
left outer join njcaa._factors p
  on (p.parameter,p.level::integer)=('p_div',t.divid)
where sf.year in (2012)
--and t.school_id is not null
order by str desc);

select
year,
exp(avg(log(str)))::numeric(4,3) as str,
exp(avg(log(park)))::numeric(4,3) as park,
exp(avg(log(ofs)))::numeric(4,3) as ofs,
exp(-avg(log(dfs)))::numeric(4,3) as dfs,
exp(avg(log(sos)))::numeric(4,3) as sos,
count(*) as n
from r
group by year
order by year asc;

select
year,
d,
exp(avg(log(str)))::numeric(4,3) as str,
exp(avg(log(park)))::numeric(4,3) as park,
exp(avg(log(ofs)))::numeric(4,3) as ofs,
exp(-avg(log(dfs)))::numeric(4,3) as dfs,
exp(avg(log(sos)))::numeric(4,3) as sos,
--avg(str)::numeric(4,3) as str,
--avg(park)::numeric(4,3) as park,
--avg(ofs)::numeric(4,3) as ofs,
--(1/avg(dfs))::numeric(4,3) as dfs,
--avg(sos)::numeric(4,3) as sos,
count(*) as n
from r
where d is not null
group by year,d
order by year asc,str desc;

select * from r
where d is null
and year=2012;

commit;
