begin;

update ncaa_pbp.box_scores_pitching
set position=''
where position is null;

commit;
