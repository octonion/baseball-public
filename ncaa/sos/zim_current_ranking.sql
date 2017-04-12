begin;

create temporary table r (
       rk	 serial,
       school 	 text,
       school_id	 integer,
       div_id	 integer,
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
(school,school_id,div_id,year,str,park,ofs,dfs,sos)
(
select
coalesce(t.school_name,sf.school_id::text),
sf.school_id,
(length(t.division)::integer) as div_id,
sf.year,
--sf.strength::numeric(4,3) as str,
(sf.strength*h.exp_factor/p.exp_factor)::numeric(4,3) as str,
--h.exp_factor::numeric(4,3) as h_div,
--p.exp_factor::numeric(4,3) as p_div,
park::numeric(4,3) as park,
offensive::numeric(4,3) as ofs,
defensive::numeric(4,3) as dfs,
--(offensive*h.exp_factor)::numeric(4,3) as ofs,
--(defensive*p.exp_factor)::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from ncaa._zim_schedule_factors sf
join ncaa.schools_divisions t
  on (t.school_id,t.year)=(sf.school_id,sf.year)
join ncaa._zim_factors h
  on (h.parameter,h.level::integer)=('h_div',length(t.division)::integer)
join ncaa._zim_factors p
  on (p.parameter,p.level::integer)=('p_div',length(t.division)::integer)
where sf.year in (2017)
--and t.division='I'
order by str desc);
--order by sos desc);

select

rank() over (order by str desc) as rk,
school,div_id as div,str,park,ofs,dfs,sos
from r
where year in (2017)
and div_id=1
order by rk asc;

--select
--rk,school,div_id as div,str,park,ofs,dfs,sos
--from r
--where year in (2017)
--where div_id=2
--and park < 0.881
--and div_id=3
--order by rk asc;

commit;
