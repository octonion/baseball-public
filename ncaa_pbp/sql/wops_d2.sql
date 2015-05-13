select
player_name as name,
position as po,
class_year as cl,
t.team_name as team,
(ab+bb+hbp) as pa,
(bb::float/(ab+bb+hbp))::numeric(4,3) as bb_p,
(k::float/(ab+bb+hbp))::numeric(4,3) as so_p,
(2*obp+slg)::numeric(4,3) as wops

from ncaa_pbp.player_summaries_hitting p
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(p.team_id,p.year)
and (ab+bb+hbp) >= 150
and p.year=2015
and t.division_id=2
order by wops desc
limit 100;

copy (
select
player_name as name,
position as po,
class_year as cl,
t.team_name as team,
(ab+bb+hbp) as pa,
(bb::float/(ab+bb+hbp))::numeric(4,3) as bb_p,
(k::float/(ab+bb+hbp))::numeric(4,3) as so_p,
(2*obp+slg)::numeric(4,3) as wops

from ncaa_pbp.player_summaries_hitting p
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(p.team_id,p.year)
and (ab+bb+hbp) >= 150
and p.year=2015
and t.division_id=2
order by wops desc
limit 100
) to '/tmp/wops_d2.csv' csv header;
