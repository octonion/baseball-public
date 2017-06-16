select
overall_pick,
--sum(war) as war,
(sum(case when war>0.0 then 1 else 0 end)::float/count(*))::numeric(4,3) as p,
count(*) as n
from bbref.draft_picks
where signed='Y'
and year<=2008
and overall_pick<=100
group by overall_pick
order by p desc;
