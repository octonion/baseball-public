begin;

select
r.year,
t.division as div,
o.division as div,
sum(case when r.school_score>r.opponent_score then 1 else 0 end) as won,
sum(case when r.school_score<r.opponent_score then 1 else 0 end) as lost,
sum(case when r.school_score=r.opponent_score then 1 else 0 end) as tied,
count(*)
from ncaa.results r
left join ncaa.schools_divisions t
  on (t.school_id,t.year)=(r.school_id,r.year)
left join ncaa.schools_divisions o
  on (o.school_id,o.year)=(r.opponent_id,r.year)
where
    t.division<=o.division
--and r.school_id < r.opponent_id
and r.year between 2008 and 2017
group by r.year,t.division,o.division
order by r.year,t.division,o.division;

commit;
