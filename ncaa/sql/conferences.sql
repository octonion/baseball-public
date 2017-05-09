select
ct.year,
ct.conference_key,
count(*) as n,
(exp(avg(ln(sf.strength))))::numeric(4,3) as str
from ncaa._schedule_factors sf
join ncaa.conferences_teams ct
  on (ct.team_id,ct.year)=(sf.school_id,sf.year)
where
    ct.year=2017
and ct.division_id=1
group by ct.year,ct.conference_key
order by str desc;

select
ct.year,
ct.conference_key,
count(*) as n,
(exp(avg(ln(sf.strength))))::numeric(4,3) as str
from ncaa._schedule_factors sf
join ncaa.conferences_teams ct
  on (ct.team_id,ct.year)=(sf.school_id,sf.year)
where
    ct.year=2017
and ct.division_id=2
group by ct.year,ct.conference_key
order by str desc;

select
ct.year,
ct.conference_key,
count(*) as n,
(exp(avg(ln(sf.strength))))::numeric(4,3) as str
from ncaa._schedule_factors sf
join ncaa.conferences_teams ct
  on (ct.team_id,ct.year)=(sf.school_id,sf.year)
where
    ct.year=2017
and ct.division_id=3
group by ct.year,ct.conference_key
order by str desc;
