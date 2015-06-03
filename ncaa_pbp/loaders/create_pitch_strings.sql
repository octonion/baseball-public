
begin;

drop table if exists ncaa_pbp.pitch_strings;

create table ncaa_pbp.pitch_strings (
       game_id		      integer,
       period_id	      integer,
       event_id		      integer,
       balls		      integer,
       strikes		      integer,
       pitch_string	      text,
       string		      text,
       primary key (game_id,period_id,event_id)
);

create temporary table ps (
       game_id		      integer,
       period_id	      integer,
       event_id		      integer,
       string		      text,
       primary key (game_id,period_id,event_id)
);

insert into ps
(
select
game_id,
period_id,
event_id,
(regexp_matches(coalesce(team_text,opponent_text), '[0-9]-[0-9] [A-Z]+'))[1] as pitch_string
from ncaa_pbp.play_by_play
);

/*
select
string,
split_part(string,'-',1) as balls,
split_part(split_part(string,' ',1),'-',2) as strikes,
split_part(string,' ',2) as pitch_string
from ps
limit 100;
*/

insert into ncaa_pbp.pitch_strings
(game_id,period_id,event_id,balls,strikes,pitch_string,string)
(
select
game_id,
period_id,
event_id,
split_part(string,'-',1)::integer as balls,
split_part(split_part(string,' ',1),'-',2)::integer as strikes,
split_part(string,' ',2) as pitch_string,
string
from ps
);

commit;
