select
game_id,
period_id,
event_id,
count(*) as n
from ncaa_pbp.play_by_play
where period_id=0
and event_id=0
group by game_id,period_id,event_id
having count(*)>1;
