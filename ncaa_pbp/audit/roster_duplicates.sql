-- For a single division

/*
select sd.school_id,sd.school_name,tr.player_name,tr.id,count(*)
from ncaa_pbp.team_rosters tr
join ncaa.schools_divisions sd
 on (sd.school_id,sd.year)=(tr.team_id,2014)
where sd.div_id=1
group by sd.school_id,sd.school_name,tr.player_name,tr.id
having count(*)>1
order by sd.school_name,tr.player_name;
*/

-- For all divisions

select tr.player_name,tr.id,count(*)
from ncaa_pbp.team_rosters tr
group by tr.player_name,tr.id
having count(*)>1
order by tr.player_name;
