select ts1.game_id
from ncaa_pbp.team_schedules ts1
join ncaa_pbp.team_schedules ts2
  on (ts2.game_id)=(ts1.game_id)
join ncaa_pbp.teams t1
  on (t1.year,t1.team_id)=(ts1.year,ts1.team_id)
join ncaa_pbp.teams t2
  on (t2.year,t2.team_id)=(ts2.year,ts2.team_id)
where t1.division_id<t2.division_id;
