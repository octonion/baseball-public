select
year,
team_key,
sum(case when signed='Y' then war else 0 end) as s,
sum(case when signed='N' then war else 0 end) as n
from bbref.draft_picks
where year<=2010
group by year,team_key
order by sum(case when signed='Y' then war else 0 end)-sum(case when signed='N' then war else 0 end) asc;
