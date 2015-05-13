begin;

create index pk_idx
on ncaa_pbp.periods (game_id,section_id);

delete from ncaa_pbp.periods per
where per.ctid <>
(select min(dup.ctid)
 from ncaa_pbp.periods dup
 where (dup.game_id,dup.section_id) =
       (per.game_id,per.section_id)
);

drop index ncaa_pbp.pk_idx;

commit;
