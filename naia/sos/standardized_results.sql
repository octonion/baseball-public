begin;

drop table if exists naia.results;

create table naia.results (
	game_date	      date,
	year		      integer,
	team_name	      text,
	team_id		      integer,
	opponent_name	      text,
	opponent_id	      integer,
	park_name	      text,
	park_id		      integer,
	field		      text,
	team_score	      integer,
	opponent_score	      integer
);

--truncate naia.results;

insert into naia.results
(game_date,year,
 team_name,team_id,
 opponent_name,opponent_id,
 park_name,park_id,field,
 team_score,opponent_score)
(
select
game_date::date,
year,
trim(both from team_name),
team_id,
trim(both from opponent_name),
opponent_id,
 (case when location='H' then trim(both from team_name)
       when location='A' then trim(both from opponent_name)
       when location='N' then 'neutral' end) as park_name,
 (case when location='H' then team_id
       when location='A' then opponent_id
       when location='N' then 0 end) as park_id,
 (case when location='H' then 'hitting_home'
       when location='A' then 'pitching_home'
       when location='N' then 'none' end) as field,
 split_part(g.score,'-',1)::integer as team_score,
 split_part(g.score,'-',2)::integer as opponent_score
 from naia.games g
 where
     g.location in ('A','H','N')
 and g.score is not null
 and g.score like '%-%'
 and g.team_id is not NULL
 and g.opponent_id is not NULL
);

insert into naia.results
(game_date,year,
 team_name,team_id,
 opponent_name,opponent_id,
 park_name,park_id,field,
 team_score,opponent_score)
(
select
game_date::date,
year,
trim(both from opponent_name),
opponent_id,
trim(both from team_name),
team_id,
 (case when location='H' then trim(both from team_name)
       when location='A' then trim(both from opponent_name)
       when location='N' then 'neutral' end) as park_name,
 (case when location='H' then team_id
       when location='A' then opponent_id
       when location='N' then 0 end) as park_id,
 (case when location='H' then 'pitching_home'
       when location='A' then 'hitting_home'
       when location='N' then 'none' end) as field,
 split_part(g.score,'-',2)::integer as team_score,
 split_part(g.score,'-',1)::integer as opponent_score
 from naia.games g
 where
     g.location in ('A','H','N')
 and g.score is not null
 and g.score like '%-%'
 and g.team_id is not NULL
 and g.opponent_id is not NULL
);

commit;
