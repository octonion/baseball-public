-- For a single division

/*
select
sd.school_id as team,
lm.player_name as name,
lm.matched_name as matched,
lm.lev_distance as lev
from ncaa_pbp.lev_mapping lm
join ncaa.schools_divisions sd
  on (sd.school_id,sd.year)=(lm.team_id,2014)
where
lm.lev_distance>=4
and length(lm.player_name)>2
and sd.div_id=1
order by lm.player_name,lm.lev_distance;
*/

-- For all divisions

select
lm.player_name as name,
lm.matched_name as matched,
lm.lev_distance as lev
from ncaa_pbp.lev_mappings lm
where
lm.lev_distance>=4
and length(lm.player_name)>2
order by lm.player_name,lm.lev_distance;
