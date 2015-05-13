
-- Add primary key to deduplicated box_scores_pitching table

alter table ncaa_pbp.box_scores_pitching
add primary key (game_id,section_id,player_name,position);
