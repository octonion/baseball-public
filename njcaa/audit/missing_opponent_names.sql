select opponent,
count(*) as n
from njcaa.game_logs gl
full outer join
njcaa.schools s
  on (s.school_name)=(gl.opponent)
where s.school_name is null
and winning_score is not null
group by opponent
order by n desc;
