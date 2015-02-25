begin;

drop table if exists njcaa.results;

create table njcaa.results (
	game_date	      date,
	year		      integer,
	team_name	      text,
	team_id		      integer,
	team_div	      integer,
	opponent_name	      text,
	opponent_id	      integer,
	opponent_div	      integer,
	park_name	      text,
	park_id		      integer,
	field		      text,
	team_score	      integer,
	opponent_score	      integer
);

insert into njcaa.results
(game_date,year,
 team_name,team_id,team_div,
 opponent_name,opponent_id,opponent_div,
 park_name,park_id,field,
 team_score,opponent_score)
(
select
game_date::date,
extract(year from game_date::date),
trim(both from home_name),
home_college_id,
home_div_id,
trim(both from visitor_name),
visitor_college_id,
visitor_div_id,
home_name as park_name,
home_college_id as park_id,
'hitting_home' as field,
 g.home_score,
 g.visitor_score
 from njcaa.games g
 where
     g.home_score is not NULL
 and g.visitor_score is not NULL
 and g.home_score >= 0
 and g.visitor_score >= 0
 and not((g.home_score,g.visitor_score)=(0,0))
 and g.home_college_id is not NULL
 and g.visitor_college_id is not NULL
 and g.home_div_id is not null
 and g.visitor_div_id is not null
);

insert into njcaa.results
(game_date,year,
 team_name,team_id,team_div,
 opponent_name,opponent_id,opponent_div,
 park_name,park_id,field,
 team_score,opponent_score)
(
select
game_date::date,
extract(year from game_date::date),
trim(both from visitor_name),
visitor_college_id,
visitor_div_id,
trim(both from home_name),
home_college_id,
home_div_id,
home_name as park_name,
home_college_id as park_id,
'pitching_home' as field,
 g.visitor_score,
 g.home_score
 from njcaa.games g
 where
     g.home_score is not NULL
 and g.visitor_score is not NULL
 and g.home_score >= 0
 and g.visitor_score >= 0
 and not((g.home_score,g.visitor_score)=(0,0))
 and g.home_college_id is not NULL
 and g.visitor_college_id is not NULL
 and g.home_div_id is not null
 and g.visitor_div_id is not null
);

commit;
