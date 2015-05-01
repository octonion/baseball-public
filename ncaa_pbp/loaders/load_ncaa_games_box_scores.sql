begin;

drop table if exists ncaa_pbp.box_scores;

create table ncaa_pbp.box_scores (
       game_id					integer,
       section_id				integer,
       player_id				integer,
       player_name				text,
       player_url				text,
       position					text,
       minutes_played				interval,
       field_goals_made				integer,
       field_goals_attempted			integer,
       three_point_field_goals_made		integer,
       three_point_field_goals_attempted	integer,
       free_throws				integer,
       free_throws_attempted			integer,
       points					integer,
       offensive_rebounds			integer,
       defensive_rebounds			integer,
       total_rebounds				integer,
       assists		     			integer,
       turnovers		     		integer,
       steals					integer,
       blocks					integer,
       fouls					integer,
       primary key (game_id, section_id, player_name)
--       primary key (game_id,team_id,player_id) --,player_name)
);

copy ncaa_pbp.box_scores from '/tmp/ncaa_games_box_scores.csv' with delimiter as E'\t' csv header;

commit;
