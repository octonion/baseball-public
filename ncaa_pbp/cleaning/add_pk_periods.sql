begin;

-- Add primary key to deduplicated periods table

alter table ncaa_pbp.periods
add primary key (game_id,section_id);

-- (game_id,team_id) must also be unique

alter table ncaa_pbp.periods
add unique (game_id,team_id);

commit;
