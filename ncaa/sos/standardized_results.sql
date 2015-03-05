begin;

drop table if exists ncaa.results;

create table ncaa.results (
	game_id		      integer,
	game_date	      date,
	year		      integer,
	school_name	      text,
	school_id	      integer,
	school_div_id	      integer,
	opponent_name	      text,
	opponent_id	      integer,
	opponent_div_id	      integer,
	park_name	      text,
	park_id		      integer,
	field		      text,
	school_score	      integer,
	opponent_score	      integer
);

insert into ncaa.results
(game_id,game_date,year,
 school_name,school_id,
 opponent_name,opponent_id,
 park_name,park_id,field,
 school_score,opponent_score)
(
select
game_id,
game_date::date,
--extract(year from game_date::date),
g.year,
trim(both from school_name),
school_id,
trim(both from opponent_name),
opponent_id,
-- s1.school_name,
-- s2.school_name,
 (case when site='Home' then trim(both from school_name)
       when site='Away' then trim(both from opponent_name)
       when site='Neutral' then 'neutral' end) as park_name,
 (case when site='Home' then school_id
       when site='Away' then opponent_id
       when site='Neutral' then 0 end) as park_id,
-- (case when site='Home' then s1.school_name
--       when site='Away' then s2.school_name
--       when site='Neutral' then 'neutral' end) as park,
 (case when site='Home' then 'hitting_home'
       when site='Away' then 'pitching_home'
       when site='Neutral' then 'none' end) as field,
 g.school_score,
 g.opponent_score
 from ncaa.games g
-- join ncaa.schools s1
--   on (s1.school_id)=(g.school_id)
-- join ncaa.schools s2
--   on (s2.school_id)=(g.opponent_id)
 where
     g.site in ('Away','Home','Neutral')
 and g.school_score is not NULL
 and g.opponent_score is not NULL
 and g.school_score >= 0
 and g.opponent_score >= 0
 and not((g.school_score,g.opponent_score)=(0,0))
 and g.school_id is not NULL
 and g.opponent_id is not NULL
-- and not(g.game_date is null)
);

insert into ncaa.results
(game_id,game_date,year,
school_name,school_id,
opponent_name,opponent_id,park_name,park_id,field,
 school_score,opponent_score)
(select
 game_id,
 game_date::date,
-- extract(year from game_date::date),
 g.year,
 trim(both from opponent_name),
opponent_id,
 trim(both from school_name),
school_id,
-- s2.school_name,
-- s1.school_name,
 (case when site='Home' then trim(both from school_name)
       when site='Away' then trim(both from opponent_name)
       when site='Neutral' then 'neutral' end) as park_name,
 (case when site='Home' then school_id
       when site='Away' then opponent_id
       when site='Neutral' then 0 end) as park_id,
-- (case when site='Home' then s1.school_name
--       when site='Away' then s2.school_name
--       when site='Neutral' then 'neutral' end) as park,
 (case when site='Home' then 'pitching_home'
       when site='Away' then 'hitting_home'
       when site='Neutral' then 'none' end) as field,
 g.opponent_score,
 g.school_score
 from ncaa.games g
-- join ncaa.schools s1
--   on (s1.school_id)=(g.school_id)
-- join ncaa.schools s2
--   on (s2.school_id)=(g.opponent_id)
 where
     g.site in ('Away','Home','Neutral')
 and g.school_score is not NULL
 and g.opponent_score is not NULL
 and g.school_score >= 0
 and g.opponent_score >= 0
 and not((g.school_score,g.opponent_score)=(0,0))
 and g.school_id is not NULL
 and g.opponent_id is not NULL
-- and not(g.game_date is null)
);

update ncaa.results
set school_div_id=sd.div_id
from ncaa.schools_divisions sd
where (sd.school_id,sd.year)=(results.school_id,results.year);

update ncaa.results
set opponent_div_id=sd.div_id
from ncaa.schools_divisions sd
where (sd.school_id,sd.year)=(results.opponent_id,results.year);

commit;
