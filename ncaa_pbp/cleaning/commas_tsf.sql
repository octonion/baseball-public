
-- Remove commas, convert to integer

begin;

update ncaa_pbp.team_summaries_fielding
set po = replace(po, ',', '');

alter table ncaa_pbp.team_summaries_fielding
  alter column po
    type integer using (po::integer);

commit;
