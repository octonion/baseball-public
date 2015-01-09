begin;

create temporary table remaps (
       team_id	       integer,
       player_name     text,
       hashed_name     text
);

copy remaps from '/tmp/team_rosters_remaps.csv' csv;

update ncaa_pbp.name_mappings
set hashed_name=r.hashed_name
from remaps r
where
(r.team_id,r.player_name)=
(name_mappings.team_id,name_mappings.player_name);

commit;
