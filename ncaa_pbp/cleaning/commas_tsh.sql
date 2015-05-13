
-- Remove commas, convert to integer

begin;

update ncaa_pbp.team_summaries_hitting
set ab = replace(ab, ',', ''),
    tb = replace(tb, ',', '');

alter table ncaa_pbp.team_summaries_hitting
  alter column ab
    type integer using (ab::integer);

alter table ncaa_pbp.team_summaries_hitting
  alter column tb
    type integer using (tb::integer);

commit;
