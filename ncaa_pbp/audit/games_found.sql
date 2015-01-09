select count(*)
from ncaa_pbp.team_schedules ts
left join ncaa_pbp.periods p
  on (ts.game_id,ts.team_id)=(p.game_id,p.team_id)
where p.section_id=1
and ts.team_score is not null
and p.game_id is not null;
