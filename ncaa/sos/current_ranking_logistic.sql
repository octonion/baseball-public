begin;

create temporary table r (
       rk	 serial,
       school 	 text,
       school_id	 integer,
       div_id	 integer,
       year	 integer,
       str	 numeric(6,2),
--       h_div	 numeric(4,3),
--       p_div	 numeric(4,3),
       ofs	 numeric(6,2),
       dfs	 numeric(6,2),
       sos	 numeric(6,2)
);

insert into r
(school,school_id,div_id,year,str,ofs,dfs,sos)
(
select
coalesce(t.school_name,sf.school_id::text),
sf.school_id,
(length(t.division)::integer) as div_id,
sf.year,
(sf.strength*h.exp_factor/p.exp_factor)::numeric(6,2) as str,
--h.exp_factor::numeric(6,2) as h_div,
--p.exp_factor::numeric(6,2) as p_div,
(offensive*h.exp_factor)::numeric(6,2) as ofs,
(defensive*p.exp_factor)::numeric(6,2) as dfs,
schedule_strength::numeric(6,2) as sos
from ncaa._schedule_factors_logistic sf
join ncaa.schools_divisions t
  on (t.school_id,t.year)=(sf.school_id,sf.year)
join ncaa._factors_logistic h
  on (h.parameter,h.level::integer)=('h_div',length(t.division)::integer)
join ncaa._factors_logistic p
  on (p.parameter,p.level::integer)=('p_div',length(t.division)::integer)
where sf.year in (2014)
--and t.division='I'
order by str desc);
--order by sos desc);

select

rank() over (order by str desc) as rk,
school,div_id as div,str,ofs,dfs,sos
from r
where year in (2014)
and div_id=1
order by rk asc;

--select
--rk,school,div_id as div,str,ofs,dfs,sos
--from r
--where year in (2014)
--where div_id=2
--and div_id=3
--order by rk asc;

commit;
