begin;

drop table if exists ncaa_pbp.player_summaries;

create table ncaa_pbp.player_summaries (
       year					integer,
       year_id					integer,
       team_id					integer,
       team_name				text,
       jersey_number				text,
       player_id				integer,
       player_name				text,
       player_url				text,
       class_year				text,
       position					text,
       height					text,
       games_played				integer,
       games_started				integer,
       minutes_played				interval,
       field_goals_made				integer,
       field_goals_attempted			integer,
       field_goal_percentage			float,
       three_point_field_goals			integer,
       three_point_field_goals_attempted	integer,
       three_point_field_goal_percentage	float,
       free_throws				integer,
       free_throws_attempted			integer,
       free_throw_percentage			float,
       points					integer,
       points_per_game				float,
       offensive_rebounds			integer,
       defensive_rebounds			integer,
       total_rebounds				integer,
       rebounds_per_game			float,
       assists					integer,
       turnovers				integer,
       steals					integer,
       blocks					integer,
       fouls					integer,
       double_doubles				integer,
       triple_doubles				integer,
       dq					integer,
       primary key (year, team_id, player_name),
       unique (year_id, team_id, player_id)
);

copy ncaa_pbp.player_summaries from '/tmp/ncaa_player_summaries.csv' with delimiter as E'\t' csv header;

commit;
