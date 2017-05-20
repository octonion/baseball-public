begin;

create temporary table r (
       school_id	 integer,
       div_id	 	 integer,
       year	 	 integer,
       str	 	 numeric(4,3),
       park	 	 numeric(4,3),
       ofs	 	 numeric(4,3),
       dfs	 	 numeric(4,3),
       sos	 	 numeric(4,3)
);

insert into r
(school_id,div_id,year,str,park,ofs,dfs,sos)
(
select
t.school_id,
t.div_id as div_id,
sf.year,
(sf.strength*h.exp_factor/p.exp_factor)::numeric(4,3) as str,
park::numeric(4,3) as park,
(offensive*h.exp_factor)::numeric(4,3) as ofs,
(defensive*p.exp_factor)::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from ncaa._schedule_factors sf
left outer join ncaa.schools_divisions t
  on (t.school_id,t.year)=(sf.school_id,sf.year)
left outer join ncaa._factors h
  on (h.parameter,h.level::integer)=('h_div',t.div_id)
left outer join ncaa._factors p
  on (p.parameter,p.level::integer)=('p_div',t.div_id)
where sf.year in (2017)
and t.school_id is not null
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
'D'||div_id as div,
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
where div_id is not null
group by year,div_id
order by year asc,str desc;

select * from r
where div_id is null
and year=2017;

commit;
