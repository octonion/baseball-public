select
player_name as name,
class_year as cl,
t.team_name as team,
sf.schedule_park::numeric(4,3) as s_p,
sf.schedule_offensive::numeric(4,3) as s_o,
so,
ip,
3*split_part(ip,'.',1)::integer+split_part(ip,'.',2)::integer as outs,
(27*so::float/(3*split_part(ip,'.',1)::integer+split_part(ip,'.',2)::integer))::numeric(3,1) as so9,

(27*bb::float/(3*split_part(ip,'.',1)::integer+split_part(ip,'.',2)::integer))::numeric(3,1) as bb9,

(go::float/fo::float)::numeric(4,2) as go_fo

from ncaa_pbp.player_summaries_pitching p
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(p.team_id,p.year)
join ncaa._schedule_factors sf
  on (sf.school_id,sf.year)=(t.team_id,t.year)
where go is not null
and fo is not null
and (3*split_part(ip,'.',1)::integer+split_part(ip,'.',2)::integer) >= 200
and p.year=2015
and t.division_id=1
order by so9 desc
limit 100;

copy (
select
player_name as name,
class_year as cl,
t.team_name as team,
sf.schedule_park::numeric(4,3) as s_p,
sf.schedule_offensive::numeric(4,3) as s_o,
so,
ip,
3*split_part(ip,'.',1)::integer+split_part(ip,'.',2)::integer as outs,
(27*so::float/(3*split_part(ip,'.',1)::integer+split_part(ip,'.',2)::integer))::numeric(3,1) as so9,

(27*bb::float/(3*split_part(ip,'.',1)::integer+split_part(ip,'.',2)::integer))::numeric(3,1) as bb9,

(go::float/fo::float)::numeric(4,2) as go_fo

from ncaa_pbp.player_summaries_pitching p
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(p.team_id,p.year)
join ncaa._schedule_factors sf
  on (sf.school_id,sf.year)=(t.team_id,t.year)
where go is not null
and fo is not null
and (3*split_part(ip,'.',1)::integer+split_part(ip,'.',2)::integer) >= 200
and p.year=2015
and t.division_id=1
order by so9 desc
limit 100
) to '/tmp/so9.csv' csv header;
