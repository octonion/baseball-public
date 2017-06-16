select
overall_pick,
sum(war)::numeric(5,1) as war,
(sum(case when war is not null or b_g is not null or p_g is not null then 1 else 0 end)::float/count(*))::numeric(4,3) as p,
count(*) as n
from bbref.draft_picks
where signed='Y'
and year<=2008
and overall_pick<=100
group by overall_pick
order by war desc;
