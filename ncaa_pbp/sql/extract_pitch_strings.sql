select
pbp.game_id,
pbp.period_id,
pbp.event_id,
(regexp_matches(coalesce(team_text,opponent_text), '[0-9]-[0-9] [A-Z]+'))[1] as pitch_string
from ncaa_pbp.play_by_play pbp
join ncaa_pbp.periods p
  on (p.game_id,p.section_id)=(pbp.game_id,0)
join ncaa_pbp.teams t
on (t.team_id,t.year)=(p.team_id,2015)
where t.division_id=1;

