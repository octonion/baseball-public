select
game_pk,game_date,
pitch_type,
avg(release_speed::float),
avg(release_spin_rate::float),
count(*)
from kershaw.pitches
where release_speed<>'null'
and release_spin_rate<>'null'
group by game_pk,game_date,pitch_type
order by game_date desc,pitch_type asc;
