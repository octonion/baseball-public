begin;

select
year,
team_name,
division_id,
count(*)
from
(select
distinct ts.year,p.team_name,t.division_id,p.game_id
from ncaa_pbp.box_scores_pitching bs
join ncaa_pbp.periods p
on (p.game_id,p.section_id)=(bs.game_id,bs.section_id)
join ncaa_pbp.team_schedules ts on (ts.team_id,ts.game_id)=(p.team_id,p.game_id)
join ncaa_pbp.teams t on (t.team_id,t.year)=(ts.team_id,ts.year)
where pitches > 0
--and ts.year in (2013,2014)
) r
group by year,team_name,division_id
order by team_name,year;

copy
(
select
year,
team_name,
division_id,
count(*)
from
(select
distinct ts.year,p.team_name,t.division_id,p.game_id
from ncaa_pbp.box_scores_pitching bs
join ncaa_pbp.periods p
on (p.game_id,p.section_id)=(bs.game_id,bs.section_id)
join ncaa_pbp.team_schedules ts on (ts.team_id,ts.game_id)=(p.team_id,p.game_id)
join ncaa_pbp.teams t on (t.team_id,t.year)=(ts.team_id,ts.year)
where pitches > 0
--and t.year in (2013,2014)
) r
group by year,team_name,division_id
order by team_name,year)
to '/tmp/pitch_strings.csv' csv header;

commit;
