select
ps.year,
ps.team_name as team,
ps.player_name as name,
ps.class_year as class,
ps.b_slg as slg
from ncaa.player_statistics ps
join ncaa.schools_divisions sd
  on (sd.year,sd.school_id)=
     (ps.year,ps.team_id)
where
    ps.b_ab>=100
and ps.b_slg>=0.900
and sd.div_id=1
and ps.year>=2002;
