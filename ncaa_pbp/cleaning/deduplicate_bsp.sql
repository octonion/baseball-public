begin;

create index pk_idx
on ncaa_pbp.box_scores_pitching (game_id,section_id,player_name,position);

delete from ncaa_pbp.box_scores_pitching bsp
where bsp.ctid <>
(select min(dup.ctid)
 from ncaa_pbp.box_scores_pitching dup
 where (dup.game_id,dup.section_id,dup.player_name,dup.position) =
       (bsp.game_id,bsp.section_id,bsp.player_name,bsp.position)
);

drop index ncaa_pbp.pk_idx;

commit;
