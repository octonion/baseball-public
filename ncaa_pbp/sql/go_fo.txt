select player_name,
(go::float/fo::float)::numeric(4,3) as go_fo
from ncaa_pbp.player_summaries_pitching p
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(p.team_id,p.year)
where go is not null
and fo is not null
and go+fo>=100
and p.year=2015
and t.division_id=1
order by go_fo desc
limit 100;

