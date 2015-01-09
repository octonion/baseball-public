select ts.team_name,ts.opponent_name,ts.game_date,ts.game_url
from ncaa_pbp.team_schedules ts
left join ncaa_pbp.periods p
  on (ts.game_id,ts.team_id)=(p.game_id,p.team_id)
where
    ts.team_score is not null
and ts.team_id < ts.opponent_id
and p.game_id is null
order by ts.game_date asc;
