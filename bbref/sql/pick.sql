select
overall_pick,
(sum(case when war is not null or b_g is not null or p_g is not null then 1 else 0 end)::float/count(*))::numeric(4,3) as p
from bbref.draft_picks
where signed='Y'
and year<=2008
group by overall_pick
order by p desc;
