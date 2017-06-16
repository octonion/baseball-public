select
year,
team_key,
sum(case when war is not null or b_g is not null or p_g is not null then 1 else 0 end) as mlb,
count(*) as n
from bbref.draft_picks
group by year,team_key order by mlb desc, n asc;
