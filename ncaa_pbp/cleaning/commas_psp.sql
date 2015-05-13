
-- Remove commas, convert to integer

begin;

update ncaa_pbp.player_summaries_pitching
set pitches = replace(pitches, ',', '');

alter table ncaa_pbp.player_summaries_pitching
  alter column pitches
    type integer using (pitches::integer);

commit;
