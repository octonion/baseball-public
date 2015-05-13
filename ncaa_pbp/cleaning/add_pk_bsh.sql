begin;

-- Add primary key to deduplicated box_scores_hitting table

alter table ncaa_pbp.box_scores_hitting
add primary key (game_id,section_id,player_name,position);

commit;
