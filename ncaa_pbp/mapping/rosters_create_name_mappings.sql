begin;

drop table if exists ncaa_pbp.name_mappings;

create table ncaa_pbp.name_mappings (
	team_id		      integer,
	player_name	      text,
	hashed_name	      text,
	id	      	      integer,
	lev_distance	      integer
);

insert into ncaa_pbp.name_mappings
(team_id,player_name)
(
select

p.team_id,
pbp.team_player
from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p
 on (p.game_id,p.team_id,p.section_id)=(g.game_id,g.team_id,0)
join ncaa_pbp.play_by_play pbp
 on (pbp.game_id)=(g.game_id)
where
    pbp.team_player is not null
and not(pbp.team_player='TEAM')

union

select
p.team_id,
pbp.team_player
from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p
 on (p.game_id,p.team_id,p.section_id)=(g.game_id,g.opponent_id,0)
join ncaa_pbp.play_by_play pbp
 on (pbp.game_id)=(g.game_id)
where
    pbp.team_player is not null
and not(pbp.team_player='TEAM')

union

select

p.team_id,
pbp.opponent_player
from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p
 on (p.game_id,p.team_id,p.section_id)=(g.game_id,g.team_id,1)
join ncaa_pbp.play_by_play pbp
 on (pbp.game_id)=(g.game_id)
where
    pbp.opponent_player is not null
and not(pbp.opponent_player='TEAM')

union

select

p.team_id,
pbp.opponent_player
from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p
 on (p.game_id,p.team_id,p.section_id)=(g.game_id,g.opponent_id,1)
join ncaa_pbp.play_by_play pbp
 on (pbp.game_id)=(g.game_id)
where
    pbp.opponent_player is not null
and not(pbp.opponent_player='TEAM')

);

commit;
