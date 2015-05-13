
-- Remove commas, convert to integer

begin;

update ncaa_pbp.team_summaries_pitching
set bf = replace(bf, ',', ''),
    p_oab = replace(p_oab, ',', ''),
    pitches = replace(pitches, ',', '');

alter table ncaa_pbp.team_summaries_pitching
  alter column bf
    type integer using (bf::integer);

alter table ncaa_pbp.team_summaries_pitching
  alter column p_oab
    type integer using (p_oab::integer);

alter table ncaa_pbp.team_summaries_pitching
  alter column pitches
    type integer using (pitches::integer);

commit;
