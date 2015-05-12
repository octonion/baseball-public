begin;

create index pk_idx
on ncaa_pbp.play_by_play (game_id,period_id,event_id);

delete from ncaa_pbp.play_by_play pbp
where pbp.ctid <>
(select min(dup.ctid)
 from ncaa_pbp.play_by_play dup
 where (dup.game_id,dup.period_id,dup.event_id) =
       (pbp.game_id,pbp.period_id,pbp.event_id)
);

drop index ncaa_pbp.pk_idx;

commit;


