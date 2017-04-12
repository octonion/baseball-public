begin;

create temporary table r (
       school_id	 integer,
       div	 text,
       year	 integer,
       str	 float,
       ofs	 float,
       dfs	 float,
       sos	 float
);

insert into r
(school_id,div,year,str,ofs,dfs,sos)
(
select
t.school_id,
t.division as div,
sf.year,
(sf.strength*h.exp_factor/p.exp_factor)::float as str,
(offensive*h.exp_factor)::float as ofs,
(defensive*p.exp_factor)::float as dfs,
schedule_strength::float as sos
from ncaa._schedule_factors_logistic sf
left outer join ncaa.schools_divisions t
  on (t.school_id,t.year)=(sf.school_id,sf.year)
left outer join ncaa._factors_logistic h
  on (h.parameter,h.level::integer)=('h_div',length(t.division))
left outer join ncaa._factors_logistic p
  on (p.parameter,p.level::integer)=('p_div',length(t.division))
where sf.year in (2017)
and t.school_id is not null
order by str desc);

select
year,
exp(avg(log(str)))::numeric(4,3) as str,
exp(avg(log(ofs)))::numeric(4,3) as ofs,
exp(avg(log(dfs)))::numeric(4,3) as dfs,
exp(avg(log(sos)))::numeric(4,3) as sos,
count(*) as n
from r
group by year
order by year asc;

select
year,
div,
exp(avg(log(str)))::numeric(4,3) as str,
exp(avg(log(ofs)))::numeric(4,3) as ofs,
exp(avg(log(dfs)))::numeric(4,3) as dfs,
exp(avg(log(sos)))::numeric(4,3) as sos,
count(*) as n
from r
where div is not null
group by year,div
order by year asc,str desc;

select * from r
where div is null
and year=2017;

commit;
