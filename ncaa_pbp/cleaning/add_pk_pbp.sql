
-- Add primary key to deduplicated play_by_play table

alter table ncaa_pbp.play_by_play
add primary key (game_id,period_id,event_id);
